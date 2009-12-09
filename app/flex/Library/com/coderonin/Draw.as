package com.coderonin
{
	import flash.display.Sprite;
	
	public class Draw
	{
		public static function rect(name:Sprite, width:Number, height:Number, lineColor:Number=0x000000, fillColor:Number=0xFFFFFF, x:Number=0, y:Number=0 ):Sprite
		{
			name.graphics.lineStyle(0, lineColor, 1);
			name.graphics.beginFill(fillColor, 1);
			name.graphics.drawRect(x ,y, width, height);
			name.graphics.endFill();
			return name
		}
		
		public static function emptyRect(name:Sprite, width:Number, height:Number, color:Number=0xFFFFFF, x:Number=0, y:Number=0 ):Sprite
		{
			name.graphics.lineStyle(0, color, 1);
			name.graphics.drawRect(x ,y, width, height);
			return name
		}
		
		public static function filledRect(name:Sprite, width:Number, height:Number, color:Number=0xFFFFFF, x:Number=0, y:Number=0 ):Sprite
		{
			name.graphics.lineStyle(0, color, 1);
			name.graphics.beginFill(color, 1);
			name.graphics.drawRect(x ,y, width, height);
			name.graphics.endFill();
			return name
		}

		public static function transRect(name:Sprite, width:Number, height:Number, x:Number=0, y:Number=0 ):Sprite
		{
			name.graphics.lineStyle(0, 0, 0);
			name.graphics.beginFill(0, 0);
			name.graphics.drawRect(x ,y, width, height);
			name.graphics.endFill();
			return name
		}
		
		public static function emptyCirc(name:Sprite, radius:Number, color:Number=0xFFFFFF, x:Number=0, y:Number=0 ):Sprite
		{
			name.graphics.lineStyle(0, color, 1);
			name.graphics.drawCircle(x, y, radius);
			return name
		}
		
		public static function filledCirc(name:Sprite, radius:Number, color:Number=0xFFFFFF, x:Number=0, y:Number=0 ):Sprite
		{
			name.graphics.lineStyle(0, color, 1);
			name.graphics.beginFill(color, 1);
			name.graphics.drawCircle(x ,y, radius);
			name.graphics.endFill();
			return name
		}
		
		public static function transCirc(name:Sprite, radius:Number, x:Number=0, y:Number=0 ):Sprite
		{
			name.graphics.lineStyle(0, 0, 0);
			name.graphics.beginFill(0, 0);
			name.graphics.drawCircle(x ,y, radius);
			name.graphics.endFill();
			return name
		}
	}
}