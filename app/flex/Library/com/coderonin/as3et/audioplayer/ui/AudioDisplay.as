package com.coderonin.as3et.audioplayer.ui
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class AudioDisplay extends Sprite
	{
		private var _id3Display:TextField;
		private var _timeDisplay:TextField;
		private var _audio:Sound;
		private var _channel:SoundChannel;
		private var _right:Shape;
		private var _left:Shape;
		
		public function set channel(value:SoundChannel):void
		{
			_channel = value;
		}
		
		public function AudioDisplay(audio:Sound)
		{
			_audio = audio;
			
			var _background:Shape = new Shape();
			_background.graphics.lineStyle(0, 0x000000, 1);
			_background.graphics.beginFill(0x000000, 1);
			_background.graphics.drawRoundRectComplex(0, 0, 350, 100, 40, 5, 40, 40);
			_background.graphics.endFill();
			addChild(_background);
			
			_id3Display = new TextField();
			_id3Display.width = 290;
			_id3Display.height = 40;
			_id3Display.x = 30;
			_id3Display.y = 10;
			addChild(_id3Display);
			
			_timeDisplay = new TextField();
			_timeDisplay.width = 290;
			_timeDisplay.height = 20;
			_timeDisplay.x = 30;
			_timeDisplay.y = 50;
			addChild(_timeDisplay);
			
			_left = new Shape();
			_left.x = 270;
			_left.y = 90;
			addChild(_left)
			
			_right = new Shape();
			_right.x = 300;
			_right.y = 90;
			addChild(_right);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(event:Event):void
		{
			for(var i:Object in _audio.id3)
			{
				trace(i);
			}
			
			if(_audio.id3.songName != null)
			{
				_id3Display.text = _audio.id3.songName + "\n";
				_id3Display.appendText( _audio.id3.artist );
			}
			
			if(_channel != null)
			{
				_timeDisplay.text = Math.round(_channel.position / 1000) + " of " + Math.round(_audio.length / 1000) + " seconds";
				
				_left.graphics.clear();
				_left.graphics.lineStyle(0, 0x000000, 1);
				_left.graphics.beginFill(0x00FF00, 1);
				_left.graphics.drawRect(0, 0, 20, -50 * _channel.leftPeak);
				_left.graphics.endFill();
				
				_right.graphics.clear();
				_right.graphics.lineStyle(0, 0x000000, 1);
				_right.graphics.beginFill(0x00FF00, 1);
				_right.graphics.drawRect(0, 0, 20, -50 * _channel.rightPeak);
				_right.graphics.endFill();
			}
			
			var format:TextFormat = new TextFormat();
			format.color = 0x00FF00;
			format.font = "_typewriter";
			
			_id3Display.setTextFormat(format);
			_timeDisplay.setTextFormat(format);
			
		}
		
	}
}