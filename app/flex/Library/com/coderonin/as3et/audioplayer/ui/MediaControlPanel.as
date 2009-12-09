package com.coderonin.as3et.audioplayer.ui
{
	import com.coderonin.as3et.ui.BevelButton;
	import com.coderonin.as3et.ui.Slider;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class MediaControlPanel extends Sprite
	{
		private var _play:BevelButton;
		private var _pause:BevelButton;		
		private var _stop:BevelButton;
		private var _scrubBar:Slider;
		private var _volumeBar:Slider;
		
		public function get volume():Number
		{
			return _volumeBar.value;
		}
		public function set volume(value:Number):void
		{
			_volumeBar.value = value;
		}

		public function get scrub():Number
		{
			return _scrubBar.value;
		}
		public function set scrub(value:Number):void
		{
			_scrubBar.value = value;
		}	
		public function set enabled(value:Boolean):void
		{
			_volumeBar.enabled = value;
			_scrubBar.enabled = value;
		}	
		
		public function MediaControlPanel()
		{
			var buttonContent:Sprite = new Sprite();
			buttonContent.graphics.lineStyle(0, 0x000000, 0);
			buttonContent.graphics.beginFill(0xFFFFFF, 1);
			buttonContent.graphics.drawRect(0, 0, 50, 50);
			buttonContent.graphics.endFill();
			
			var label:TextField = new TextField();
			label.autoSize = TextFieldAutoSize.LEFT;
			label.text = "play";
			label.x = 25 - label.width / 2;
			label.y = 25 - label.height / 2;
			buttonContent.addChild(label);
			
			_play = new BevelButton(buttonContent);
			_play.addEventListener(MouseEvent.CLICK, onPlay);
			addChild(_play);
			
			label.text = "pause";
			label.x = 25 - label.width / 2;
			label.y = 25 - label.height / 2;			

			_pause = new BevelButton(buttonContent);
			_pause.addEventListener(MouseEvent.CLICK, onPause);
			addChild(_pause);	
			
			label.text = "stop";
			label.x = 25 - label.width / 2;
			label.y = 25 - label.height / 2;			

			_stop = new BevelButton(buttonContent);
			_stop.addEventListener(MouseEvent.CLICK, onStop);
			_stop.x = _play.width;
			addChild(_stop);	
			
			_scrubBar = new Slider(200);
			_scrubBar.x = 120;
			_scrubBar.y = 10;
			_scrubBar.addEventListener(Event.CHANGE, onScrub);
			addChild(_scrubBar);
			
			_volumeBar = new Slider(100);
			_volumeBar.x = 120;
			_volumeBar.y = 40;
			_volumeBar.value = 1;
			_volumeBar.addEventListener(Event.CHANGE, onVolume);
			addChild(_volumeBar);
			
		}
		
		private function onPlay(event:Event):void
		{
			removeChild(_play);
			addChild(_pause);
			dispatchEvent(new Event("play"));
		}

		private function onPause(event:Event):void
		{
			removeChild(_pause);
			addChild(_play);
			dispatchEvent(new Event("pause"));
		}

		private function onStop(event:Event):void
		{
			dispatchEvent(new Event("stop"));
			if(_pause.parent == this)
			{
				removeChild(_pause);
				addChild(_play);
			}
		}

		private function onScrub(event:Event):void
		{
			dispatchEvent(new Event("scrub"));
		}
		
		private function onVolume(event:Event):void
		{
			dispatchEvent(new Event("volume"));
		}
	}
}