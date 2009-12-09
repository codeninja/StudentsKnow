package com.coderonin.flvplayer.ui
{
	import com.coderonin.flvplayer.graphics.RectGradient;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.effects.Tween;
	import mx.effects.easing.Circular;
	
	public class VolumeControl extends Sprite
	{	
		[Embed(source="library.swf", symbol="background_gradient")]
		private var BackgroundAsset:Class;
		[Embed(source="library.swf", symbol="btn_vol_off")]
		private var VolOffAsset:Class;	
		[Embed(source="library.swf", symbol="btn_vol_low")]
		private var VolLowAsset:Class;	
		[Embed(source="library.swf", symbol="btn_vol_mid")]
		private var VolMidAsset:Class;	
		[Embed(source="library.swf", symbol="btn_vol_full")]
		private var VolFullAsset:Class;	
		
		private var _volOff:Button;
		private var _volLow:Button;
		private var _volMid:Button;
		private var _volFull:Button;
		private var _value:Number;
		
		private var _volSlider:Sprite;
		private var _scrubBar:ScrubberBar;
		
		private var _delay:Timer;
		private var _panelTweening:Boolean;
		private var _panelExtended:Boolean;
		
		public function get value():Number
		{
			return _value;
		}
		public function set value(value:Number):void
		{
			_value = value;
		}
		
		public function VolumeControl()
		{
			var background:RectGradient = new RectGradient(30, 30, 0x4B4B4B, 0x2B2B2B);
			addChild(background);
			
			var _volOffContent:Sprite = new VolOffAsset();
			_volOff = new Button(_volOffContent);
			_volOff.name = "off";
			_volOff.addEventListener(MouseEvent.CLICK, onVolFull);
			_volOff.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			_volOff.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);

			var _volLowContent:Sprite = new VolLowAsset();			
			_volLow = new Button(_volLowContent);
			_volLow.name = "low";
			_volLow.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			_volLow.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			var _volMidContent:Sprite = new VolMidAsset();	
			_volMid = new Button(_volMidContent);
			_volMid.name = "mid";
			_volMid.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			_volMid.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			var _volFullContent:Sprite = new VolFullAsset();	
			_volFull = new Button(_volFullContent);
			_volFull.name = "full";
			_volFull.addEventListener(MouseEvent.CLICK, onVolOff);
			_volFull.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			_volFull.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			addChild(_volFull);
			
			_volSlider = new Sprite();
			_volSlider.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			_volSlider.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			var _backgroundAsset:Sprite = new BackgroundAsset();
			_backgroundAsset.width = 60

			_scrubBar = new ScrubberBar(50);
			_scrubBar.x = 5;
			_scrubBar.y = 9;
			_scrubBar.value = 1;
			_scrubBar.addEventListener(Event.CHANGE, onVolume);
			
			_volSlider.addChild(_backgroundAsset);
			_volSlider.addChild(_scrubBar);
			
			addChildAt(_volSlider, 0);
			_volSlider.rotation = -90;
			_volSlider.y = _volSlider.height;
			_volSlider.visible = false;
			
			_delay = new Timer(1000, 1);
			_delay.addEventListener(TimerEvent.TIMER, onDelayComplete);
			
		}
		
		private function onMouseOver(event:MouseEvent):void
		{
			if(!_panelTweening && !_panelExtended)
			{
				_panelTweening = true;
				var t:Tween = new Tween(_volSlider, _volSlider.height, 0, 500);
				t.easingFunction = Circular.easeOut;
				t.setTweenHandlers(updateTween, endTween);
				_volSlider.visible = true
			}
			
			_delay.stop();
		}
		
		
		private function updateTween(val:int):void
		{
			_volSlider.y = val
		}
		
		private function endTween(pos:Number):void 
		{
			if(pos==0)//panel slid out
			{
				_panelExtended=true;
				_panelTweening=false;
			}
			else//panel slid back
			{
				_panelExtended=false;
				_panelTweening=false;
				_volSlider.visible = false;	
			}
		}
		
		private function onMouseOut(event:MouseEvent):void
		{
			_delay.start();
		}
		
		private function onDelayComplete(event:TimerEvent):void
		{
			if(!_panelTweening && _panelExtended)
			{
				_panelTweening = true;
				var t:Tween = new Tween(_volSlider, 0, _volSlider.height, 1000);
				t.easingFunction = Circular.easeOut;
				t.setTweenHandlers(updateTween, endTween);
				_volSlider.visible = true
			}
			
		}
		
		private function onVolFull(event:MouseEvent):void
		{
			removeChild(_volOff);
			addChild(_volFull);
			_value = _scrubBar.value = 1;
			dispatchEvent(new Event("vol_full"));
		}

		private function onVolOff(event:MouseEvent):void
		{
			removeChild(_volFull);
			addChild(_volOff);
			_value = _scrubBar.value = 0;
			dispatchEvent(new Event("vol_off"));
		}

		private function onVolume(event:Event):void
		{
			_value = _scrubBar.value;
			
			removeButtons();
			
			if(_value == 0)
			{
				addChild(_volOff);
			}
			else if(_value < .33)
			{
				addChild(_volLow);
			}
			else if(_value < .66)
			{
				addChild(_volMid);
			}
			else if(_value < 1)
			{
				addChild(_volFull);
			}
			
			dispatchEvent(new Event(Event.CHANGE));
		}
			
		private function removeButtons():void
		{
			var off:DisplayObject = DisplayObjectContainer(this).getChildByName("off");
			var low:DisplayObject = DisplayObjectContainer(this).getChildByName("low");
			var mid:DisplayObject = DisplayObjectContainer(this).getChildByName("mid");
			var full:DisplayObject = DisplayObjectContainer(this).getChildByName("full");
			if(off != null)
			{
				removeChild(_volOff);
			}
			if(low != null)
			{
				removeChild(_volLow);
			}
			if(mid != null)
			{
				removeChild(_volMid);
			}
			if(full != null)
			{
				removeChild(_volFull);
			}
		}	
	}
}