package game.ui;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;

class UIText {
	/**
	 * Screen-space bitmap text for HUD panels.
	 */
	public static function make(x:Float, y:Float, text:String, font:FlxBitmapFont, color:FlxColor):FlxBitmapText {
		var t = new FlxBitmapText(font);
		t.x = x;
		t.y = y;
		t.color = color;
		t.scrollFactor.set(0, 0);
		t.text = text;
		return t;
	}
}
