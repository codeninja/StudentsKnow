package com.coderonin.flvplayer.ui
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	public class MetaModel extends EventDispatcher
	{
		private static var _instance:MetaModel;

		private var _data:XML;
		private var _loaded:Boolean;
		private var _error:String;

		public function get loaded():Boolean
		{
			return _loaded;
		}
		
		public function get data():XML
		{
			return _data;
		}
		
		public function MetaModel(enforcer:SingletonEnforcer){}
		
		public static function getInstance(metaURL:String):MetaModel
		{
			if(MetaModel._instance == null)
			{
				MetaModel._instance = new MetaModel( new SingletonEnforcer() );
				MetaModel._instance.loadXML(metaURL);
			}
			return MetaModel._instance;
		}

		public function loadXML(metaURL:String):void
		{
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.load( new URLRequest(metaURL) );
		}

		private function onLoadComplete(event:Event):void
		{
			try {
				_data = new XML( event.target.data );
				_loaded = true;
								
				trace("MetaModel XML Load Successful");
				dispatchEvent(new Event("onLoadComplete"));
			} 
			catch (e:TypeError) {
				_error = e.message;
				_loaded = false;
				trace("MetaModel XML Load Failed: "+_error);
				dispatchEvent(new Event("onLoadFailed"));
			}
		}

	}
	
}

class SingletonEnforcer {}