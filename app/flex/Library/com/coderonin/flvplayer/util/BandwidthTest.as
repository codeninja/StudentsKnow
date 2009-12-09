package com.coderonin.flvplayer.util
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	public class BandwidthTest extends Sprite
	{
		private var _startDownload:Number;
		private var _kbps:Number;
		
		private var _loader:URLLoader;
		private var _testURL:String = "http://www.rightactionscript.com/samplefiles/Bandwidth.jpg";
		
		public function get kbps():Number
		{
			return _kbps;
		}
		
		public function BandwidthTest()
		{
			var request:URLRequest = new URLRequest(_testURL);
			
			_loader = new URLLoader();
			_loader.load(request);
			_loader.addEventListener(Event.OPEN, onTestStart);
			_loader.addEventListener(Event.COMPLETE, onTestComplete);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onTestStatus);
		}
		
		private function onTestStart(event:Event):void
		{
			_startDownload = getTimer();
		}
		
		private function onTestComplete(event:Event):void
		{
			var totalTime:Number = getTimer() - _startDownload;
			var bytes:uint = _loader.bytesTotal;
			var seconds:Number = totalTime / 1000;
			var kilobits:Number = bytes * 8 / 1000;
			_kbps = kilobits / seconds;
			dispatchEvent(new Event("testComplete"));
		}
		
		private function onTestStatus(event:Event):void
		{
			if(event.type.toString()=='netStatus')
			{
				if(NetStatusEvent(event).info['level']=="error")
				{
					trace("ERROR - " + NetStatusEvent(event).info['code'])
				}
			}
		}
		
	}
}