package
{
	import com.coderonin.Draw;
	import com.coderonin.flvplayer.ui.AdvertPanel;
	import com.coderonin.flvplayer.ui.AdvertView;
	import com.coderonin.mp3player.SoundControlPanel;
	import com.coderonin.flvplayer.ui.MetaModel;
	import com.coderonin.flvplayer.ui.MetaView;
	import com.coderonin.flvplayer.util.BandwidthTest;

	import com.coderonin.mp3player.SoundFacade;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.*;
	import flash.media.Sound;
	import flash.system.Security;
	import flash.utils.Timer;
		
	public class MP3Player extends MovieClip
	{
		private var _width:Number = 460;
		private var _height:Number = 380;
		private var _background:Sprite;
		private var _loadTimer:Timer;

		private var _sound:SoundFacade;

		private var _controlPanel:SoundControlPanel;
		private var _cpState:String;
		private var _duration:Number;
		private var _test:BandwidthTest;
		
		private var _metaView:MetaView;
		private var _advertView:AdvertView;
		private var _advertPanel:AdvertPanel;
		
		private var _metaURL:String;
		private var _advertURL:String;
		
		public function MP3Player()
		{
			trace(flash.system.Security.sandboxType);
			
			_metaURL = root.loaderInfo.parameters.metaURL;	
			trace(_metaURL)		
			
			_advertURL = root.loaderInfo.parameters.advertURL;
			trace(_advertURL)		
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			_background = new Sprite();
			Draw.filledRect(_background, _width, (_height-30), 0x000000);
			addChildAt(_background, 0);

			_metaView = new MetaView(_metaURL, _width, (_height-30));
			_metaView.addEventListener("onLoadComplete", playAudio);
			addChildAt(_metaView, 1);	
			
			_advertView = new AdvertView(_advertURL, _width, (_height-30));
			_advertView.visible = false;	
			addChildAt(_advertView, 2);						

			_advertPanel = new AdvertPanel(_advertURL, _width, 70);
			_advertPanel.y = (_height-30);
			addChildAt(_advertPanel, 3);		
			
			_duration = 0;
			drawControlBar(_width, (_height-30));
		}
				
		private function drawControlBar(hSpace:Number, vPlacement:Number, state:String='playing', fullScreen:Boolean=false):void
		{
			var existingControl:DisplayObject = getChildByName("playerControl");
			if(existingControl != null)
			{
				removeChild(_controlPanel);
				_controlPanel = null;
			}

			_controlPanel = new SoundControlPanel(hSpace, state, fullScreen);
			_controlPanel.enabled = false;
			_controlPanel.name = "playerControl";
			_controlPanel.y = vPlacement;
			_controlPanel.addEventListener("play", onPlay);
			_controlPanel.addEventListener("pause", onPause);
			_controlPanel.addEventListener("stop", onStop);
			_controlPanel.addEventListener("volume", onVolume);
			_controlPanel.addEventListener("scrub", onScrub);
						
			addChildAt(_controlPanel, 4);
		}
			
		private function playAudio(event:Event):void
		{   
			var _model:MetaModel = MetaModel.getInstance(_metaURL);
			trace(_model.data.stream);

			_sound = new SoundFacade(_model.data.stream, true, true, true, 100000);
			
			_sound.addEventListener(flash.events.ProgressEvent.PROGRESS, onLoadProgress);
			_sound.addEventListener(flash.events.Event.OPEN, onLoadOpen);
			_sound.addEventListener(flash.events.Event.COMPLETE, onLoadComplete);
			_sound.addEventListener("playProgress", onPlayProgress);
			_sound.addEventListener(flash.events.Event.SOUND_COMPLETE, onPlayComplete);
			
			_cpState = 'playing';
		}
				
		private function onLoadProgress(event:ProgressEvent):void
		{
			_controlPanel.loaded = (event.bytesLoaded / event.bytesTotal);
		}
		
		private function onLoadOpen(event:Event):void
		{
			trace('onLoadOpen');
			_controlPanel.enabled = true;
		}
		
		private function onLoadComplete(event:Event):void
		{
			trace('onLoadComplete');
		}

		private function onPlayProgress(event:ProgressEvent):void
		{
			_controlPanel.scrub = (event.bytesLoaded / event.bytesTotal);
			_controlPanel.ctime = _controlPanel.scrub * (_sound.s.length)
			_controlPanel.duration = (_sound.s.length)
		}	

		private function onPlayComplete(event:Event):void
		{
			trace('onPlayComplete');
			_advertPanel.extended = false;
			_advertView.visible = true;
			_cpState = 'completed';
			_controlPanel.setState(_cpState);
		}
					
		private function onPlay(event:Event):void
		{
			_advertView.visible = false;
			_advertPanel.reset();	
			_sound.resume();
			_cpState = 'playing';
			_controlPanel.setState(_cpState);
		}
		
		private function onPause(event:Event):void
		{
			_sound.pause();
			_cpState = 'paused';
			_controlPanel.setState(_cpState);
		}
		
		private function onStop(event:Event):void
		{
			_sound.stop();
			_controlPanel.scrub = 0;
			_controlPanel.ctime = 0;
			_cpState = 'stopped';
			_controlPanel.setState(_cpState);
		}
		
		private function onVolume(event:Event):void
		{
			_sound.volume = _controlPanel.volume
		}
		
		private function onScrub(event:Event):void
		{
			_sound.stop();
			_sound.play(_controlPanel.scrub * (_sound.s.length));
			_controlPanel.ctime = _controlPanel.scrub * (_sound.s.length)
		}
		
	}
}