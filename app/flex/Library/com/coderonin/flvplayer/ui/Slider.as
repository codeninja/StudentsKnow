package com.coderonin.flvplayer.ui
{
	import com.coderonin.Draw;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class Slider extends Sprite
	{
		private var _width:Number;
		private var _thumb:BevelButton;
		private var _track:Sprite;
		private var _buttonPressed:Boolean;
		private var _enabled:Boolean;
		
		public function get value():Number
		{
			return((_thumb.x+5) / _track.width)
		}
		
		//take a value range between zero and 1
		public function set value(sliderValue:Number):void
		{
			if(!_buttonPressed)
			{
				if(sliderValue>1)
				{
					sliderValue = 1;
				}
				else if(sliderValue < 0)
				{
					sliderValue = 0;
				}
				_thumb.x = (_track.width * sliderValue) -5;				
			}
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
		
		public function Slider(width:Number)
		{
			_width = width;
			_enabled = true;
			
			drawTrack();
			addChild(_track);
			
			drawButton();
			addChild(_thumb);
			
			_thumb.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		private function drawTrack():void
		{
			_track = new Sprite();
			Draw.rect(_track, _width, 4, 0x444444, 0x000000);
			_track.y = -2
		}
		
		private function drawButton():void
		{
			var _buttonShape:Sprite = new Sprite();
			Draw.rect(_buttonShape, 10, 10, 0x000000, 0xFFFFFF);
			
			_thumb = new BevelButton(_buttonShape, true);
			_thumb.x = -5;
			_thumb.y = -5;
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			root.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			root.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_buttonPressed = true;
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			_thumb.x = mouseX - 5;
			if(_thumb.x > _track.width -5)
			{
				_thumb.x = _track.width -5;
			}
			else if(_thumb.x < -5)
			{
				_thumb.x = -5;
			}
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			root.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			root.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_buttonPressed = false;
		}
	}
}