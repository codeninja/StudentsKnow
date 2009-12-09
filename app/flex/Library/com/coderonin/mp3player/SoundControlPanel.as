package com.coderonin.mp3player
{
	import com.coderonin.flvplayer.ui.*;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class SoundControlPanel extends Sprite
	{
		[Embed(source="library.swf", symbol="background_gradient")]
		private var BackgroundAsset:Class;		
		[Embed(source="library.swf", symbol="btn_play")]
		private var BtnPlayAsset:Class;
		[Embed(source="library.swf", symbol="btn_pause")]
		private var BtnPauseAsset:Class;		
		[Embed(source="library.swf", symbol="btn_stop")]
		private var BtnStopAsset:Class;
		[Embed(source="library.swf", symbol="btn_fullscreen")]
		private var BtnFullScreenAsset:Class;
		[Embed(source="library.swf", symbol="btn_normalscreen")]
		private var BtnNormalScreenAsset:Class;
		[Embed(source="library.swf", symbol="btn_logo")]
		private var BtnLogoAsset:Class;
						

		private var _duration:Number;
		private var _playPos:TextField;
		private var _playPosTf:TextFormat = new TextFormat(null, 10, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.LEFT);
		private var _playDur:TextField;
		private var _playDurTf:TextFormat = new TextFormat(null, 10, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.RIGHT);
		private var _canFullScreen:Boolean;
		private var _play:SwfButton;
		private var _pause:SwfButton;		
		private var _stop:SwfButton;
		private var _logo:SwfButton;
		private var _volume:VolumeControl;
		private var _scrubBar:ScrubberBar;
		private var _fullScreen:SwfButton;
		private var _normalScreen:SwfButton;
		private var _volumeBar:Slider;

		public function set duration(value:Number):void
		{
			_duration = value;
			_playDur.text = formatFrames(_duration/1000);
			_playDur.setTextFormat(_playDurTf);
		}
		public function get duration():Number
		{
			return _duration;
		}
		
		public function get loaded():Number
		{
			return _scrubBar.load;
		}
		public function set loaded(value:Number):void
		{
			_scrubBar.load = value;
		}		

		public function get volume():Number
		{
			return _volume.value;
		}
		public function set volume(value:Number):void
		{
			_volume.value = value;
		}

		public function get scrub():Number
		{
			return _scrubBar.value;
		}
		public function set scrub(value:Number):void
		{
			_scrubBar.value = value;
		}
		
		public function set ctime(current:Number):void
		{
			_playPos.text = formatFrames(current/1000);
			_playPos.setTextFormat(_playPosTf);
		}
			
			
		public function set enabled(value:Boolean):void
		{
			if(_volumeBar)
			{
				_volumeBar.enabled = value;				
			}
			_scrubBar.enabled = value;
		}	
		
		public function SoundControlPanel(hSpace:Number, state:String, fullScreen:Boolean=false)
		{			
			_canFullScreen = checkFullScreen();
			_canFullScreen = false;

			var _backgroundAsset:Sprite = new BackgroundAsset();
			_backgroundAsset.width = hSpace;
			_backgroundAsset.height = 30;
			addChild(_backgroundAsset);
						
			var _playContent:Sprite = new BtnPlayAsset();
			_play = new SwfButton(_playContent);
			_play.addEventListener(MouseEvent.CLICK, onPlay);
			addChild(_play);
			_play.visible = false;
			
			var _pauseContent:Sprite = new BtnPauseAsset();
			_pause = new SwfButton(_pauseContent);
			_pause.addEventListener(MouseEvent.CLICK, onPause);
			addChild(_pause);
			var scrubWidth:Number = hSpace - _pause.width;

			var _stopContent:Sprite = new BtnStopAsset();
			_stop = new SwfButton(_stopContent);
			_stop.addEventListener(MouseEvent.CLICK, onStop);
			_stop.x = 30;
			addChild(_stop);
			scrubWidth -= _stop.width;

			_volume = new VolumeControl();
			_volume.addEventListener("vol_full", onVolume);
			_volume.addEventListener("vol_off", onVolume);
			_volume.addEventListener(Event.CHANGE, onVolume);
			_volume.x = hSpace - _volume.width;
			addChild(_volume);
			scrubWidth -= _volume.width;
			
			var _logoContent:Sprite = new BtnLogoAsset();
			_logo = new SwfButton(_logoContent);
			_logo.x = hSpace - (_volume.width + _logo.width);
			addChild(_logo);
			scrubWidth -= _logo.width;
			
			if(_canFullScreen)
			{
				var _fullScreenContent:Sprite = new BtnFullScreenAsset();
				_fullScreen = new SwfButton(_fullScreenContent);
				_fullScreen.addEventListener(MouseEvent.CLICK, onFullScreen);
				_fullScreen.x = hSpace - (_volume.width + _logo.width + _fullScreen.width);
								
				var _normalScreenContent:Sprite = new BtnNormalScreenAsset();
				_normalScreen = new SwfButton(_normalScreenContent);
				_normalScreen.addEventListener(MouseEvent.CLICK, onNormalScreen);		
				_normalScreen.x = hSpace - (_volume.width + _logo.width + _fullScreen.width);				
				
				if(fullScreen)
				{
					addChild(_normalScreen);	
				}
				else
				{
					addChild(_fullScreen);	
				}
				
				scrubWidth -= _fullScreen.width;
			}

			_scrubBar = new ScrubberBar(scrubWidth-10);
			_scrubBar.x = _pause.width + _stop.width + 5;
			_scrubBar.y = 10;
			_scrubBar.addEventListener(Event.CHANGE, onScrub);
			_scrubBar.addEventListener(MouseEvent.MOUSE_OVER, showTextFields);
			_scrubBar.addEventListener(MouseEvent.MOUSE_OUT, hideTextFields);
			
			_playPos = new TextField();
			_playPos.text = "00:00:00";
			_playPos.setTextFormat(_playPosTf);
			_playPos.x = _scrubBar.x;
			
			_playDur = new TextField();
			_playDur.text = "00:00:00";
			_playDur.setTextFormat(_playDurTf);
			_playDur.x = _scrubBar.x + _scrubBar.width - _playDur.width;
			
			hideTextFields(null);

			addChild(_playPos);
			addChild(_playDur);
			addChild(_scrubBar);
			setState(state);			
		}
		
		private function formatFrames(seconds:Number):String
		{
			var hours:Number = Math.floor(seconds / (60*60));
			var mins:Number = Math.floor(seconds / (60)) - (hours * (60*60)) ;
			var secs:Number = Math.floor(seconds) - (mins * 60);			
			var frames:String;
			
			if(hours <= 0)
			{
				frames = "00:";
			}		
			else if(hours < 10) 
			{ 
				frames = "0"+hours+":"; 
			}
			else
			{
				frames = hours+":";
			}

			if(mins <= 0)
			{
				frames += "00:";
			}		
			else if(mins < 10) 
			{ 
				frames += "0"+mins+":"; 
			}
			else
			{
				frames += mins+":";
			}
			
			if(secs <= 0)
			{
				frames += "00";
			}		
			else if(secs < 10) 
			{ 
				frames += "0"+secs; 
			}
			else
			{
				frames += secs;
			}

			return frames;
		}
		
		private function checkFullScreen():Boolean
		{
			var info:String = Capabilities.version;
			var info_arr:Array = info.split(" ");
			var versionCodes:Array = info_arr[1].split(","); 
			if(versionCodes[0]>=9 && versionCodes[2]>=28)
			{
				return true;
			}
			return false;  
		}

        private function onNetStat(event:NetStatusEvent):void
        {
            if(event.info.code == "NetStream.Play.Stop") 
            {
            	onPlayComplete(event);
            }      
        }
        			
		private function onPlay(event:Event):void
		{
			setState('playing');
			dispatchEvent(new Event("play"));
		}
		
		private function onPlayComplete(event:Event):void
		{
			setState('completed');
			hideTextFields(event);
			dispatchEvent(new Event("complete"));			
		}

		private function onPause(event:Event):void
		{
			setState('paused');
			dispatchEvent(new Event("pause"));
		}

		private function onStop(event:Event):void
		{
			setState('stopped');
			dispatchEvent(new Event("stop"));
		}

		public function setState(state:String):void
		{
			if(state=='paused')
			{
				
				_pause.visible = false;
				_play.visible = true;
			}
			else if(state=='stopped')
			{
				_pause.visible = false;
				_play.visible = true;
			}
			else if(state=='playing')
			{
				_pause.visible = true;
				_play.visible = false;
	
				_stop.visible = true;
				_scrubBar.visible = true;
//				_fullScreen.visible = true;
//				_normalScreen.visible = true;
				_volume.visible = true;
			}
			else if(state=='completed')
			{
				_pause.visible = false;
				_play.visible = true;
				
				_stop.visible = false;
				_scrubBar.visible = false;
	//			_fullScreen.visible = false;
	//			_normalScreen.visible = false;
				_volume.visible = false;
			}
		}

		private function onScrub(event:Event):void
		{
			dispatchEvent(new Event("scrub"));
		}
		
		private function onFullScreen(event:Event):void
		{
			dispatchEvent(new Event("fullScreen"));
		}

		private function onNormalScreen(event:Event):void
		{
			dispatchEvent(new Event("normalScreen"));
		}
		
		private function onVolume(event:Event):void
		{
			dispatchEvent(new Event("volume"));
		}
	
		private function showTextFields(event:Event):void
		{
			_playPos.visible = true;
			_playDur.visible = true;
		}

		private function hideTextFields(event:Event):void
		{
			_playPos.visible = false;
			_playDur.visible = false;
		}
	}
}