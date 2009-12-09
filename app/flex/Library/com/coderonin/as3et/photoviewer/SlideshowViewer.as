package com.coderonin.as3et.photoviewer
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.events.TimerEvent;
	
	public class SlideshowViewer extends flash.display.Sprite
	{
		private var _loader:Loader;
		private var _bitmap:Bitmap;
		private var _bitmapData:BitmapData;
		private var _temporaryBitmapData:BitmapData;
		private var _disolveTimer:Timer;
		private var _randomValue:uint;
		
		public function SlideshowViewer()
		{
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadMain);
			
			_bitmapData = new BitmapData(400, 400, true, 0xFFFFFF);
			_bitmap = new Bitmap(_bitmapData);
			addChild(_bitmap);
			
			_disolveTimer = new Timer(10, 30);
			_disolveTimer.addEventListener(TimerEvent.TIMER, onDisolveTimer);
		}
		
		public function loadNext(imageUrl:String):void
		{
			var request:URLRequest = new URLRequest(imageUrl);
			_loader.load(request);
		}
		
		private function onLoadMain(event:Event):void
		{
			var scaleFactor:Number = 400 / Math.max(_loader.width, _loader.height);
			
			_temporaryBitmapData = new BitmapData(400, 400, true, 0xFFFFFF);
			
			var offsetX:Number = (400 - _loader.width * scaleFactor) / 2;
			var offsetY:Number = (400 - _loader.height * scaleFactor) / 2;
			
			_temporaryBitmapData.draw(_loader, new Matrix(scaleFactor, 0, 0, scaleFactor, offsetX, offsetY));
			_randomValue = 0;
			_disolveTimer.reset();
			_disolveTimer.start();
		}
		
		private function onDisolveTimer(event:TimerEvent):void
		{
			_randomValue = _bitmapData.pixelDissolve(_temporaryBitmapData, new Rectangle(0, 0, 400, 400), new Point(0, 0), _randomValue, 400 * 400 / 30);
		}
	}
}