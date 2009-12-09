package com.coderonin.flvplayer.ui
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	public class AdvertModel extends EventDispatcher
	{
		private static var _instance:AdvertModel;
		private var _advertURL:String;
		private var _data:XML;
		private var _loaded:Boolean;
		private var _error:String;
		private var _length:Number = -1; //iniitalize length to -1 so that 0 refers to first element
		

		public function get loaded():Boolean
		{
			return _loaded;
		}
		
		public function get data():XML
		{
			return _data;
		}
		
		public function get advertisements():XMLList
		{
			return _data.advertisement
		}

		public function get length():Number
		{
			return _length;
		}
		
		public function AdvertModel(enforcer:SingletonEnforcer){}
		
		public static function getInstance(advertURL:String):AdvertModel
		{
			if(AdvertModel._instance == null)
			{
				AdvertModel._instance = new AdvertModel( new SingletonEnforcer() );
				AdvertModel._instance.loadXML(advertURL);
			}
			return AdvertModel._instance;
		}

		public function loadXML(advertURL:String):void
		{
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.load( new URLRequest(advertURL) );
		}
				
		private function onLoadComplete(event:Event):void
		{
			try {
				_data = new XML( event.target.data );
				_loaded = true;
				
				var advertisements:XMLList = _data.advertisement;				
				for each (var advertisement:XML in advertisements)
				{
					_length += 1;
				}
				
				trace("AdvertModel XML Load Successful");
				dispatchEvent(new Event("onLoadComplete"));
			} 
			catch (e:TypeError) {
				_error = e.message;
				_loaded = false;
				trace("AdvertModel XML Load Failed: "+_error);
				dispatchEvent(new Event("onLoadFailed"));
			}
		}
	}
}

class SingletonEnforcer {}