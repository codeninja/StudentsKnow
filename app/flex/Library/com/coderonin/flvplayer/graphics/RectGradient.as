package com.coderonin.flvplayer.graphics
{
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.geom.Matrix;

	public class RectGradient extends Sprite
	{
		public function RectGradient(width:Number, height:Number, topColor:Number, midColor:Number)
		{
			var background:Sprite = new Sprite();

			var fillType:String = GradientType.LINEAR;
//			var colors:Array = [topColor, midColor, midColor, topColor];
			var colors:Array = [topColor, midColor];
//			var alphas:Array = [1, 1, 1, 1];
			var alphas:Array = [1, 1];
//			var ratios:Array = [0, 55, 200, 255];
			var ratios:Array = [0, 255];
						
			var rotation:Number = 2 * Math.PI * (90 / 360);
			var matr:Matrix = new Matrix();
			matr.createGradientBox(width, height, rotation, 0, 0);
			
			var spreadMethod:String = SpreadMethod.PAD;
			
			background.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod); 
			background.graphics.drawRect(0, 0, width, height);
			
			addChild(background);
		}
	}
}