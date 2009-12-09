package com.coderonin.flvplayer.ui
{
	import com.coderonin.Draw;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
			
	public class MetaView extends Sprite
	{
		private var _metaURL:String;
		private var _width:Number;
		private var _height:Number;
		public var _background:Sprite;
		
		private var _model:MetaModel;

		private var _label:TextField;
		private var _labelTf:TextFormat = new TextFormat(null, 12, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.RIGHT);
		
		private var _metaTf:TextFormat = new TextFormat(null, 20, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.LEFT);
		
				
		public function MetaView(metaURL:String, width:Number, height:Number)
		{
			_width = width;
			_height = height;
			
			_metaURL = metaURL;
			
			_model = MetaModel.getInstance(metaURL);
			_model.addEventListener("onLoadComplete", drawView);
		}

		private function drawView(event:Event):void
		{
			dispatchEvent(new Event("onLoadComplete"));
			
			_background = new Sprite();
			Draw.filledRect(_background, _width, _height, 0x000000);
			addChild(_background);
						
			_label = new TextField();
			_label.text = "Meta Description";
			_label.setTextFormat(_labelTf);
			addChild(_label);
			_label.x = _background.width - (_label.width +5)
			_label.y = 5;
			
			var y:Number = 5;
			
			var name:TextField = new TextField();
			name.text = _model.data.name;
			name.setTextFormat(_metaTf);
			addChild(name);
			name.width = _background.width-40;	
			name.x =20;
			name.y = y+=25;
			
			var description:TextField = new TextField();
			description.text = _model.data.description;
			description.setTextFormat(_metaTf);
			addChild(description);
			description.multiline = true;
			description.wordWrap = true;
			description.width = _background.width-40;	
			description.height = 75;
			description.x =20;
			description.y = y+=25;
			
			var university:TextField = new TextField();
			university.text = _model.data.university;
			university.setTextFormat(_metaTf);
			addChild(university);
			university.width = _background.width-40;	
			university.x =20;
			university.y = y+=75;

			var class_number:TextField = new TextField();
			class_number.text = _model.data.class_number;
			class_number.setTextFormat(_metaTf);
			addChild(class_number);
			class_number.width = _background.width-40;	
			class_number.x =20;
			class_number.y = y+=25;	

			var professor:TextField = new TextField();
			professor.text = _model.data.professor;
			professor.setTextFormat(_metaTf);
			addChild(professor);
			professor.width = _background.width-40;	
			professor.x =20;
			professor.y = y+=25;

			var subject:TextField = new TextField();
			subject.text = _model.data.subject;
			subject.setTextFormat(_metaTf);
			addChild(subject);
			subject.width = _background.width-40;	
			subject.x =20;
			subject.y = y+=25;		

			var book_title:TextField = new TextField();
			book_title.text = _model.data.book_title;
			book_title.setTextFormat(_metaTf);
			addChild(book_title);
			book_title.width = _background.width-40;	
			book_title.x =20;
			book_title.y = y+=25;	

			var book_author:TextField = new TextField();
			book_author.text = _model.data.book_author;
			book_author.setTextFormat(_metaTf);
			addChild(book_author);
			book_author.width = _background.width-40;	
			book_author.x =20;
			book_author.y = y+=25;	

			var chapter:TextField = new TextField();
			chapter.text = _model.data.chapter;
			chapter.setTextFormat(_metaTf);
			addChild(chapter);
			chapter.width = _background.width-40;	
			chapter.x =20;
			chapter.y = y+=25;	

			var isbn:TextField = new TextField();
			isbn.text = _model.data.isbn;
			isbn.setTextFormat(_metaTf);
			addChild(isbn);
			isbn.width = _background.width-40;	
			isbn.x =20;
			isbn.y = y+=25;	
		}
	}
}
