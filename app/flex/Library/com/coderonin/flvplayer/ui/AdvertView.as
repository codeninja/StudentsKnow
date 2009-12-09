package com.coderonin.flvplayer.ui
{
	import com.coderonin.Draw;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;

	public class AdvertView extends Sprite
	{
		private var _advertURL:String;
		private var _width:Number;
		private var _height:Number;
		public var _background:Sprite;
		
		private var _model:AdvertModel;
		private var _advertisements:XMLList;

		[Embed(source="library.swf", symbol="btn_close")]
		private var BtnCloseAsset:Class;
		[Embed(source="library.swf", symbol="btn_next")]
		private var BtnNextAsset:Class;		
		[Embed(source="library.swf", symbol="btn_previous")]
		private var BtnPreviousAsset:Class;
		
		private var _next:SwfButton;
		private var _previous:SwfButton;

		private var _label:TextField;
		private var _labelTf:TextFormat = new TextFormat(null, 12, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.RIGHT);
		
		private var _index:Number = 0;	
			
		public function AdvertView(advertURL:String, width:Number, height:Number)
		{
			_width = width;
			_height = height;
			
			_advertURL = advertURL;
			
			_model = AdvertModel.getInstance(advertURL);
			_model.addEventListener("onLoadComplete", drawView);
		}
					
		private function drawView(event:Event):void
		{
			_background = new Sprite();
			Draw.filledRect(_background, _width, _height, 0x000000);
			addChild(_background);
						
			_label = new TextField();
			_label.text = "Advertisement";
			_label.setTextFormat(_labelTf);
			addChild(_label);
			_label.x = _background.width - (_label.width +5)
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
		}
		
		private function drawAdverts(index:Number):void
		{
			_index = getValidIndex(index);
			index = _index;

			for(var i:Number = 0; i < 3 ; i++)
			{
				var nextItem:Number = getValidIndex(index + i);
				if(_advertisements[nextItem])
				{
					var advertItem:AdvertItem = new AdvertItem(_advertisements[nextItem]);
					advertItem.x = 100;
					advertItem.y = 40+(i*100);
					advertItem.name = i.toString();
					advertItem.addEventListener("onClick", onAdvertItemClick);
					addChild(advertItem)					
				}
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
			for(var i:Number = 0; i <= 3; i++)
			{
				var existingAd:DisplayObject = getChildByName(i.toString());
				if(existingAd != null)
				{
					removeChild(existingAd);
				}
			}
		}
		
		private function onNext(event:Event):void
		{
			clearAdverts();
			drawAdverts(_index+3);
		}
		
		private function onPrevious(event:Event):void
		{
			clearAdverts();
			drawAdverts(_index-3);
		}
		
		private function onAdvertItemClick(event:Event):void
		{
			navigateToURL(new URLRequest(event.currentTarget.url));
		}
	}
}