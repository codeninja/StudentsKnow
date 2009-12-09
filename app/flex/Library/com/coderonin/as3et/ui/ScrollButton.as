package com.coderonin.as3et.ui
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class ScrollButton extends Sprite
	{
		private var _button:BevelButton;
		
		public function ScrollButton(direction:uint)
		{
			var content:Sprite = new Sprite();
			content.graphics.lineStyle(0, 0, 0);
			content.graphics.beginFill(0xFFFFFF, 1);
			content.graphics.drawRoundRect(0, 0, 20, 20, 4, 4);
			content.graphics.endFill();
			content.graphics.beginFill(0x000000, 1);
			if(direction == 0)
			{
				content.graphics.moveTo(6, 6);
				content.graphics.lineTo(14, 6);
				content.graphics.lineTo(10, 14);
				content.graphics.lineTo(6, 6);
			}
			else
			{
				content.graphics.moveTo(6, 14);
				content.graphics.lineTo(14, 14);
				content.graphics.lineTo(10, 6);
				content.graphics.lineTo(6, 14);
			}
			content.graphics.endFill();
			
			var button:BevelButton = new BevelButton(content, true);
			_button = button;
			addEventListener(Event.ADDED, onAdded);
		}
		
		private function onAdded(event:Event):void
		{
			addChild(_button);
		}
	}
}