package com.coderonin.flvplayer.ui
{
	import com.coderonin.Draw;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BevelFilter;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	public class SwfButton extends flash.display.SimpleButton
	{
		private var _content:DisplayObject;
		private var _timer:Timer;
		
		public function SwfButton(content:*, repeat:Boolean=false)
		{
			/**
			 * if content is a srting when we assume that we are to load button content from a url
			 */
			if(content is String)
			{
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, draw);
				
				var request:URLRequest = new URLRequest(String(content));
				loader.load(request);
				_content = loader;
			}
			/**
			 * if content is a DisplayObject then we are drawing a bevel on to the DisplayObject
			 */
			else if (content is DisplayObject)
			{
				_content = DisplayObject(content);
				draw(null);
			}
			
			if(repeat)
			{
				addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				_timer = new Timer(50);
				_timer.addEventListener(TimerEvent.TIMER, onTimer);
				addEventListener(Event.ENTER_FRAME, drawEmptyBackground);
			}
		}
		
		private function draw(event:Event):void
		{
			/**
			 * create bitmapData from content
			 */
			var bitmapData:BitmapData = new BitmapData(_content.width, _content.height, true, 0xFFFFFF);
			bitmapData.draw(_content);
			
			/**
			 * create bitmaps for our three button states
			 */
			var up:Bitmap = new Bitmap(bitmapData);
			
			var over:Sprite = new Sprite();
			over.addChild(_content);
			
			var down:Bitmap = new Bitmap(bitmapData);
			
			/**
			 * create color transform for button over state - slightly darker
			 * assign color transofrm to over state bitmap
			 */
			var colorTransform:ColorTransform = new ColorTransform(.9, .9, .9);
			over.transform.colorTransform = colorTransform;

			/**
			 * create color transform for button down state - much darker
			 * assign color transofrm to down state bitmap
			 */
			colorTransform = new ColorTransform(.5, .5, .5);
			down.transform.colorTransform = colorTransform;
			
			/**
			 * assign our newly created bitmaps to the button states
			 */
			upState = up;
			overState = over;
			downState = down;
			hitTestState = up;
		}

		/**
		 * draw an empty symbol at root to help capture mouse events when mouse if off our button
		 * we create an onEnterFrame event to continually fire so that we do not attempt to draw 
		 * this symbol before root and stave avleuse are present and then remove the onEnterFrame event 
		 * once the background is drawn.
		 * we ensure that we only draw one background by naming the symbol before adding it to root
		 * and only draw if the repeat parameter is supplied to our contructor
		 **/
		private function drawEmptyBackground(event:Event):void
		{
			if(stage != null && root != null)//make sure root and stage are accessible
			{
				var existingBackground:DisplayObject = DisplayObjectContainer(root).getChildByName("mouseEventDispatcherBackground");
				if(existingBackground == null)
				{
					var transparent:Sprite = new Sprite();
					Draw.transRect(transparent, stage.stageWidth, stage.stageHeight);
					transparent.name = "mouseEventDispatcherBackground";
					
					DisplayObjectContainer(root).addChildAt(transparent, 0);
				}
				removeEventListener(Event.ENTER_FRAME, drawEmptyBackground);					
			}
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			_timer.start();
			root.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			_timer.stop();
			root.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		private function onTimer(event:TimerEvent):void
		{
			dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}	
	}
}