package com.coderonin.flvplayer.ui
{
	import com.coderonin.Draw;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	import mx.effects.Tween;
	import mx.effects.easing.Circular;
		
	public class AdvertPanel extends Sprite
	{
		private var _advertURL:String;
		private var _width:Number;
		private var _height:Number;
		
		private var _model:AdvertModel;
		private var _advertisements:XMLList;

		[Embed(source="library.swf", symbol="background_gradient")]
		private var BackgroundAsset:Class;
		[Embed(source="library.swf", symbol="btn_close")]
		private var BtnCloseAsset:Class;
		[Embed(source="library.swf", symbol="btn_next")]
		private var BtnNextAsset:Class;		
		[Embed(source="library.swf", symbol="btn_previous")]
		private var BtnPreviousAsset:Class;
		
		private var _background:Sprite;
		private var _backgroundAsset:Sprite;
		private var _close:SwfButton;
		private var _next:SwfButton;
		private var _previous:SwfButton;

		private var _label:TextField;
		private var _labelTf:TextFormat = new TextFormat(null, 12, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.RIGHT);
		
		private var _index:Number = 0;	

		private var _appearDelayTimer:Timer;
		private var _appearDelayTime:Number = 15000;
		private var _panelTweening:Boolean;
		private var _panelExtended:Boolean;
		private var _openY:Number;
		private var _closedY:Number;
		
		private var _slideTimer:Timer;
		private var _slideTime:Number = 30000;
		
		public function get extended():Boolean
		{
			return _panelExtended;
		}
		
		public function set extended(value:Boolean):void
		{
			trace("set extended("+value+")")
			trace(_panelExtended);
			
			if(value)
			{
				if(!_panelExtended)
				{
					tweenPanelOpen();	
				}
			}
			else
			{
				if(_panelExtended)
				{
					tweenPanelClosed();					
				}
				if(!(_appearDelayTimer==null)) _appearDelayTimer.stop();
				if(!(_slideTimer==null)) _slideTimer.stop();
			}
		}
		
		public function AdvertPanel(advertURL:String, width:Number, height:Number)
		{
			_width = width;
			_height = height;
			
			_advertURL = advertURL;
			
			_model = AdvertModel.getInstance(advertURL);
			_model.addEventListener("onLoadComplete", drawView);
		}
		
		public function reset():void
		{
			if(!(_appearDelayTimer==null)) _appearDelayTimer.stop();
			if(!(_slideTimer==null)) _slideTimer.stop();
			
			_appearDelayTimer = new Timer(_appearDelayTime, 1);
			_appearDelayTimer.addEventListener(TimerEvent.TIMER, onAppearDelayComplete);
			_appearDelayTimer.start();			
		}
		
		public function redraw(newWidth:Number, newClosedY:Number):void
		{
			_closedY = newClosedY;
			_openY = this._closedY - _height;
			
			if(_panelExtended)
			{
				y = _openY;
			}
			else
			{
				y = _closedY;
			}
						
			_width = newWidth;
			_background.width = _width;
			_backgroundAsset.width = _width;
			_close.x = _background.width - 20;
			_label.x = _background.width - (_label.width +_close.width +5);
			_next.x = _background.width - 20;
			_previous.x = _background.width - 40;
		}
		
		private function drawView(event:Event):void
		{
			_background = new Sprite();
			Draw.filledRect(_background, _width, _height, 0x000000);
			addChild(_background);
			_background.transform.colorTransform = new ColorTransform(1, 1, 1, .5, 0, 0, 0, 0);
			
			_backgroundAsset = new BackgroundAsset();
			_backgroundAsset.width = _width;
			_backgroundAsset.height = 4;
			
			addChild(_backgroundAsset);
			
			var _closeContent:Sprite = new BtnCloseAsset();
			_close = new SwfButton(_closeContent);
			_close.addEventListener(MouseEvent.CLICK, onClose);
			_close.x = _background.width - 20
			_close.y = 5;
			addChild(_close);
			
			_label = new TextField();
			_label.text = "Advertisement";
			_label.setTextFormat(_labelTf);
			addChild(_label);
			_label.x = _background.width - (_label.width +_close.width +5)
			_label.y = 5;
			
			var _nextContent:Sprite = new BtnNextAsset();
			_next = new SwfButton(_nextContent);
			_next.addEventListener(MouseEvent.CLICK, onNext);
			_next.x = _background.width - 20;
			_next.y = _background.height - 20;
			addChild(_next);
			
			var _previousContent:Sprite = new BtnPreviousAsset();
			_previous = new SwfButton(_previousContent);
			_previous.addEventListener(MouseEvent.CLICK, onPrevious);
			_previous.x = _background.width - 40;
			_previous.y = _background.height - 20;
			addChild(_previous);
			
			_advertisements = _model.advertisements;
			drawAdverts(_index);

			_closedY = this.y;
			_openY = this.y - _height;
			
			reset();
		}
		
		private function drawAdverts(index:Number):void
		{
			_index = getValidIndex(index);
			index = _index;
			var nextItem:Number = getValidIndex(index);
			if(_advertisements[nextItem])
			{
				var advertItem:AdvertItem = new AdvertItem(_advertisements[nextItem], false);
				advertItem.x = 10;
				advertItem.y = 5;
				advertItem.name = "1";
				advertItem.addEventListener("onClick", onAdvertItemClick);
				addChild(advertItem)					
			}
		}
		
		private function getValidIndex(index:Number):Number
		{
			if(index < 0)
			{
				return _model.length + index + 1
			}
			else if(index <= _model.length)
			{
				return index;
			}
			else if(index > _model.length)
			{
				return (index-1) - _model.length
			}
			return 0;
		}
		
		private function clearAdverts():void
		{
			for(var i:Number = 1; i <= 1; i++)
			{
				var existingAd:DisplayObject = getChildByName(i.toString());
				if(existingAd != null)
				{
					removeChild(existingAd);
				}
			}
		}
		
		private function onClose(event:Event):void
		{
			tweenPanelClosed();
			_slideTimer.stop();
			_appearDelayTimer.stop();
		}
		
		private function onNext(event:Event):void
		{
			clearAdverts();
			drawAdverts(_index+1);
		}
		
		private function onPrevious(event:Event):void
		{
			clearAdverts();
			drawAdverts(_index-1);
		}
		
		private function onAdvertItemClick(event:Event):void
		{
			navigateToURL(new URLRequest(event.currentTarget.url));
		}
		
		private function onAppearDelayComplete(event:TimerEvent):void
		{
			if(!_panelTweening && !_panelExtended)
			{
				tweenPanelOpen();
			}
			_slideTimer = new Timer(_slideTime);
			_slideTimer.addEventListener(TimerEvent.TIMER, onNext);
			_slideTimer.start();
		}
		
		private function tweenPanelOpen():void
		{
			_panelTweening = true;
			var t:Tween = new Tween(this, _closedY, _openY, 1000);
			t.easingFunction = Circular.easeOut;
			t.setTweenHandlers(updateTween, endTween);
		}
		
		private function tweenPanelClosed():void
		{
			_panelTweening = true;
			var t:Tween = new Tween(this, _openY, _closedY, 1000);
			t.easingFunction = Circular.easeOut;
			t.setTweenHandlers(updateTween, endTween);
		}

		private function updateTween(val:int):void
		{
			this.y = val
		}
		
		private function endTween(pos:Number):void 
		{
			var out:Number = 280;
			if(pos==out)//panel slid out
			{
				_panelExtended=true;
				_panelTweening=false;
			}
			else//panel slid back
			{
				_panelExtended=false;
				_panelTweening=false;
			}
		}
		
	}
}