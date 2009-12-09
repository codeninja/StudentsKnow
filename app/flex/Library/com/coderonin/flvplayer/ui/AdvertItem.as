package com.coderonin.flvplayer.ui
{
	import com.coderonin.Draw;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class AdvertItem extends Sprite
	{
		private var _hitArea:Sprite;
		private var _tfWidth:Number = 300;
		private var _titleTf:TextFormat = new TextFormat(null, 18, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.LEFT);
		private var _bodyTf:TextFormat = new TextFormat(null, 14, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.LEFT);
		private var _urlTf:TextFormat = new TextFormat(null, 14, 0xFADD00, null, null, null, null, null, TextFormatAlign.LEFT);

		private var _url:String;
		
		public function get url():String
		{
			return _url;
		}
		
		public function AdvertItem(item:Object, full:Boolean=true)
		{				
			_url = item.url;
			
			var title:TextField = new TextField();
			title.selectable = false;
			title.text = item.title;
			title.width = _tfWidth;
			title.setTextFormat(_titleTf);
			addChild(title);

			var body1:TextField = new TextField();
			body1.selectable = false;
			body1.text = item.body1;
			body1.width = _tfWidth;
			body1.setTextFormat(_bodyTf);
			addChild(body1);
			body1.y = 22;

			if(full)
			{
				var body2:TextField = new TextField();
				body2.selectable = false;
				body2.text = item.body2;
				body2.width = _tfWidth;
				body2.setTextFormat(_bodyTf);
				addChild(body2);
				body2.y = 40;
			}
			
			var url:TextField = new TextField();
			url.selectable = false;
			url.text = item.url;
			url.width = _tfWidth;
			url.setTextFormat(_urlTf);
			addChild(url);
			if(full)
			{
				url.y = 60;	
			}
			else
			{
				url.y = 40;	
			}
			

			_hitArea = new Sprite();
			Draw.filledRect(_hitArea, 300, 80, 0x999999);
			addChild(_hitArea);
			_hitArea.alpha = 0;
						
			if(_url != null)
			{
				_hitArea.buttonMode = true;
				_hitArea.useHandCursor = true;
				_hitArea.addEventListener(MouseEvent.CLICK, onClick);					
			}
			
		}
		
		private function onClick(event:Event):void
		{
			dispatchEvent(new Event("onClick"));
		}
	}
}