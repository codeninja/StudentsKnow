package com.coderonin.flvplayer.ui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	
	public class ScrubberBar extends Sprite
	{
		private var _thumb:Button;
		private var _track:Sprite;
		private var _trackBackground:Sprite;
		private var _loadProgress:Sprite;
		private var _playProgress:Sprite;
		private var _buttonPressed:Boolean;
		private var _enabled:Boolean;
		
		private var _bevel:BevelFilter;
		
		public function get value():Number
		{
			return(((_thumb.x) / _track.width)-.025)
		}
		//take a value range between zero and 1
		public function set value(sliderValue:Number):void
		{
			if(!_buttonPressed)
			{
				if(sliderValue > 1)
				{
					sliderValue = 1;
				}
				else if(sliderValue < 0)
				{
					sliderValue = 0;
				}
				_thumb.x = _track.x + (_track.width * sliderValue) - 4 ;
				_playProgress.width = (_track.width * sliderValue);		
			}
		}

		public function get load():Number
		{
			return(_loadProgress.width / _trackBackground.width);
		}
		
		public function set load(loadValue:Number):void
		{
			if(loadValue>1)
			{
				loadValue = 1;
			}
			else if(loadValue < 0)
			{
				loadValue = 0;
			}
			_loadProgress.width = (_trackBackground.width * loadValue);	
		}

		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			_thumb.enabled = value;
			if(value)
			{
				_thumb.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
			else
			{
				_thumb.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
		}
		
		public function ScrubberBar(width:Number)
		{
			_bevel = new BevelFilter(1, 235);
			
			drawTrackBackground(width);							
			drawLoadProgress(width);
			drawPlayProgress(width);
			drawTrack(width);
			drawButton();
		}
		
		private function drawTrackBackground(width:Number):void
		{
			_trackBackground = new Sprite();
			_trackBackground.graphics.lineStyle(0, 0, 0);
			_trackBackground.graphics.beginFill(0xFFFFFF, 1);
			_trackBackground.graphics.drawRoundRect(0, 0, width, 12, 12, 12);
			_trackBackground.graphics.endFill();
			_trackBackground.filters = [_bevel];
			addChild(_trackBackground);
		}
		
		private function drawTrack(width:Number):void
		{
			width = width - 10;
			_track = new Sprite();
			_track.graphics.lineStyle(0, 0, 0);
			_track.graphics.beginFill(0xCCCCCC, 1);
			_track.graphics.drawRoundRect(0, 0, width, 4, 4, 4);
			_track.graphics.endFill();
			_track.x = 5;
			_track.y = 5;
			_track.alpha = 0;
			_track.addEventListener(MouseEvent.MOUSE_DOWN, onTrackClick);
			addChild(_track);
		}
		
		private function drawLoadProgress(width:Number):void
		{
			_loadProgress = new Sprite();
			_loadProgress.graphics.lineStyle(0, 0, 0);
			_loadProgress.graphics.beginFill(0x999999, 1);
			_loadProgress.graphics.drawRoundRect(0, 0, width, 12, 12, 12);
			_loadProgress.graphics.endFill();
			_loadProgress.filters = [_bevel];
			addChild(_loadProgress);
		}
		
		private function drawPlayProgress(width:Number):void
		{
			width = width - 10;
			_playProgress = new Sprite();
			_playProgress.graphics.lineStyle(0, 0, 0);
			_playProgress.graphics.beginFill(0x000000, 1);
			_playProgress.graphics.drawRoundRect(0, 0, width, 4, 4, 4);
			_playProgress.graphics.endFill();
			_playProgress.x = 5;
			_playProgress.y = (_trackBackground.height - _playProgress.height) / 2;
			_playProgress.width=0;
			addChild(_playProgress);
		}
		
		private function drawButton():void
		{
			var content:Sprite = new Sprite();
			content.graphics.lineStyle(0, 0, 0);
			content.graphics.beginFill(0x000000, 1);
			content.graphics.drawCircle(4, 4, 4);
			content.graphics.endFill();

			_thumb = new Button(content);
			_thumb.x = _track.x-2;
			_thumb.y = (_trackBackground.height - _thumb.height) / 2;
			addChild(_thumb);
			
			_thumb.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			root.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			root.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_buttonPressed = true;
		}

		private function onMouseMove(event:MouseEvent):void
		{
			_thumb.x = mouseX;
			
			if(_thumb.x > _track.x + _track.width -4)
			{
				_thumb.x = _track.x + _track.width -4;
			}
			else if(_thumb.x < _track.x - 4)
			{
				_thumb.x = _track.x - 4;
			}
			_playProgress.width = (_thumb.x - _playProgress.x);	

			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			root.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			root.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_buttonPressed = false;
		}

		private function onTrackClick(event:MouseEvent):void
		{
			onMouseMove(event);
		}
	}
}