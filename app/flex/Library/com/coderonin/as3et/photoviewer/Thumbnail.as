package com.coderonin.as3et.photoviewer
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.net.URLRequest;

	public class Thumbnail extends Sprite
	{
		private var _loader:Loader;
		private var _width:Number;
		private var _height:Number;
		private var _mainAssetUrl:String;
		private var _scaleFactorX:Number;
		private var _scaleFactorY:Number;
		
		
		public function get mainAssetUrl():String
		{
			return _mainAssetUrl;
		}
		
		public function Thumbnail(url:String, mainUrl:String, defaultWidth:Number, defaultHeight:Number)
		{
			_width = defaultWidth;
			_height = defaultHeight;
			_mainAssetUrl = mainUrl;
			_loader = new Loader();
			
			var request:URLRequest = new URLRequest(url);
			
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, setDefaultState);
			_loader.load(request);
			_loader.addEventListener(MouseEvent.MOUSE_OVER, gotoMouseOverState);
			_loader.addEventListener(MouseEvent.MOUSE_OUT, gotoDefaultState);
			
			addChild(_loader);
		}
		
		private function setDefaultState(event:Event):void
		{
			_scaleFactorX = _width / Math.max(_loader.width, _loader.height);
			_scaleFactorY = _height / Math.max(_loader.width, _loader.height);
			gotoDefaultState(event)
		}
		
		private function gotoDefaultState(event:Event):void
		{
			_loader.scaleX = _scaleFactorX * .9;
			_loader.scaleY = _scaleFactorY * .9;
			_loader.filters = [new DropShadowFilter()];
			center();
		}
		
		private function gotoMouseOverState(event:Event):void
		{
			_loader.scaleX = _scaleFactorX * .99;
			_loader.scaleY = _scaleFactorY * .99;
			_loader.filters = [new DropShadowFilter(10, 45, 0x222222, 1, 10, 10)];	
			center();		
		}
		
		private function center():void
		{
			_loader.x = (_width - _loader.width) / 2;
			_loader.y = (_height - _loader.height) / 2;
		}
	}
}