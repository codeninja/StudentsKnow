package
{
	import com.coderonin.Draw;
	import com.coderonin.flvplayer.ui.AdvertPanel;
	import com.coderonin.flvplayer.ui.AdvertView;
	import com.coderonin.flvplayer.ui.MediaControlPanel;
	import com.coderonin.flvplayer.util.BandwidthTest;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.Security;
	import flash.utils.Timer;
		
	public class FLVPlayer extends MovieClip
	{
		private var _width:Number = 460;
		private var _height:Number = 380;
		private var _background:Sprite;
		private var _loadTimer:Timer;
		private var _stream:NetStream;
		private var _video:Video;
		private var _videoWidth:Number;
		private var _videoHeight:Number;
		private var _defScaleX:Number;
		private var _defScaleY:Number;
		
		private var _controlPanel:MediaControlPanel;
		private var _cpState:String;
		private var _duration:Number;
		private var _test:BandwidthTest;
		
		private var _advertView:AdvertView;
		private var _advertPanel:AdvertPanel;
		
		private var _videoURL:String;
		private var _advertURL:String;
		
		public function FLVPlayer()
		{
			trace(flash.system.Security.sandboxType);
						
			_videoURL = root.loaderInfo.parameters.videoURL;
			_advertURL = root.loaderInfo.parameters.advertURL;
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener( FullScreenEvent.FULL_SCREEN, fullScreenRedraw);

			_background = new Sprite();
			Draw.filledRect(_background, _width, (_height-30), 0x000000);
			addChildAt(_background, 0);

			var connection:NetConnection = new NetConnection();
			connection.connect(null);			
			
			_stream = new NetStream(connection);
			
			_video = new Video(_width, (_height-30));
			_video.visible = false;
			_video.attachNetStream(_stream);
			addChildAt(_video, 1);
			
			_advertView = new AdvertView(_advertURL, _width, (_height-30));
			_advertView.visible = false;	
			addChildAt(_advertView, 2);						

			_advertPanel = new AdvertPanel(_advertURL, _width, 70);
			_advertPanel.y = (_height-30);
			addChildAt(_advertPanel, 3);		
			
			_duration = 0;
			drawControlBar(_width, (_height-30));
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		
			playVideo();
			
		}
				
		private function drawControlBar(hSpace:Number, vPlacement:Number, state:String='playing', fullScreen:Boolean=false):void
		{
			var existingControl:DisplayObject = getChildByName("playerControl");
			if(existingControl != null)
			{
				removeChild(_controlPanel);
				_controlPanel = null;
			}

			_controlPanel = new MediaControlPanel(_stream, hSpace, state, fullScreen);
			_controlPanel.name = "playerControl";
			_controlPanel.y = vPlacement;
			_controlPanel.addEventListener("play", onPlay);
			_controlPanel.addEventListener("pause", onPause);
			_controlPanel.addEventListener("stop", onStop);
			_controlPanel.addEventListener("volume", onVolume);
			_controlPanel.addEventListener("scrub", onScrub);
			
			if(fullScreen)
			{
				_controlPanel.addEventListener("normalScreen", onNormalScreen);
			}
			else
			{
				_controlPanel.addEventListener("fullScreen", onFullScreen);
			}
			
			addChildAt(_controlPanel, 4);
		}
			
		private function playVideo():void
		{   
			var clientObject:Object = new Object();
			clientObject.onMetaData = onMetaData;
			
			_stream.bufferTime = 2;
			_stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStat);
			_stream.play(_videoURL);
			_stream.client = clientObject;	

			_loadTimer = new Timer(100)
			_loadTimer.addEventListener(TimerEvent.TIMER, onLoadProgress);
			_loadTimer.start();
		}
		
		private function positionVideo():void
		{
			var scaleFactorX:Number;
			var scaleFactorY:Number;
			
			_video.width = _background.width*_defScaleX;
			_video.height = _background.height*_defScaleY;
						
			if(_video.width <= _background.width)
			{
				_video.x = (_background.width - _video.width) / 2;
			}
			
			if(_video.height <= _background.height)
			{
				_video.y = (_background.height - _video.height) / 2;
			}	
		}
		
		private function onLoadProgress(event:TimerEvent):void
		{
			_controlPanel.loaded = _stream.bytesLoaded/_stream.bytesTotal;
			if(_controlPanel.loaded == 1)
			{
				_loadTimer.stop();
			}
		}
		
		private function onMetaData(data:Object):void
		{
//			trace(data)
//			for(var i:Object in data)
//			{
//				trace(i+"="+data[i]);
//			}	

			var width:Number = data.width;
			var height:Number = data.height;
			var aspect:Number = height/width;

			if(width > _width)
			{
				width = _width;
				height = width*aspect;
			}

			_videoWidth = width;
			_videoHeight = height;

			_video.width = _videoWidth;
			_video.height = _videoHeight;
			
			_defScaleX = _video.scaleX;
			_defScaleY = _video.scaleY;

			_duration = data.duration;
			_controlPanel.duration = _duration;
			positionVideo();
			_video.visible = true;
		}

        private function onNetStat(event:NetStatusEvent):void
        {
            if(event.info.code == "NetStream.Play.Stop") 
            {
                _stream.pause();
                _stream.seek(0);
                onPlayComplete();
            }      	
        }
		
		private function onEnterFrame(event:Event):void
		{
			if(_stream != null)
			{
				_controlPanel.scrub = _stream.time / _duration;
			}
		}
		
		private function onPlay(event:Event):void
		{
			_advertView.visible = false;
			_advertPanel.reset();	
			_stream.resume();
			_cpState = 'playing';
		}
		
		private function onPlayComplete():void
		{
			_advertPanel.extended = false;
			_advertView.visible = true;
			_cpState = 'completed';
		}
		
		private function onPause(event:Event):void
		{
			_stream.pause();
			_cpState = 'paused';
		}
		
		private function onStop(event:Event):void
		{
			_stream.seek(0);
			_stream.pause();
			_cpState = 'stopped';
			positionVideo();
		}
		
		private function onVolume(event:Event):void
		{
			var soundTransform:SoundTransform = _stream.soundTransform;
			soundTransform.volume = _controlPanel.volume;
			_stream.soundTransform = soundTransform;
		}
		
		private function onScrub(event:Event):void
		{
			_stream.seek(_controlPanel.scrub * _duration);
		}
		
		private function onFullScreen(event:Event):void
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
		}
		
		private function onNormalScreen(event:Event):void
		{
			stage.displayState = StageDisplayState.NORMAL;
		}
		
		private function fullScreenRedraw(event:FullScreenEvent):void
		{			
			if(event.fullScreen)
			{	
				_background.width = stage.fullScreenWidth;
				_background.height = (stage.fullScreenHeight-30);
							
				_advertView.width = stage.fullScreenWidth;
				_advertView.height = stage.fullScreenHeight;
trace("AdvertView : "+ _advertView.width +" x "+ _advertView.height );
trace("AdvertView : "+ _advertView.scaleX +" x "+ _advertView.scaleY );
				_advertPanel.redraw(_background.width, _background.height);
								
				drawControlBar(_background.width, _background.height, _cpState, true);
				
				positionVideo();
			}
			else
			{
				_background.width = _width;
				_background.height = (_height-30);
				
				_advertView.scaleX = 1;
				_advertView.scaleY = 1;

trace("AdvertView : "+ _advertView.width +" x "+ _advertView.height );
trace("AdvertView : "+ _advertView.scaleX +" x "+ _advertView.scaleY );

				_advertPanel.redraw(_background.width, _background.height);
				
				drawControlBar(_background.width, _background.height, _cpState);
				
				positionVideo();
			}
		}
	}
}