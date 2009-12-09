package com.coderonin.flvplayer.graphics
{
	import flash.display.Sprite;

	public class PlayButton extends Sprite
	{
		public function PlayButton()
		{
			var btnPlay:Sprite = new Sprite();
			btnPlay.graphics.lineStyle(0, 0, 0);
			btnPlay.graphics.beginFill(0xFFFFFF, 1);
			btnPlay.graphics.drawRect(0, 0, 30, 30);
			btnPlay.graphics.endFill();
			btnPlay.graphics.beginFill(0x000000, 1);
			btnPlay.graphics.moveTo(10, 7);
			btnPlay.graphics.lineTo(23, 15);
			btnPlay.graphics.lineTo(10, 23);
			btnPlay.graphics.lineTo(10, 7);
			btnPlay.graphics.endFill();
			addChild(btnPlay);
		}
	}
}