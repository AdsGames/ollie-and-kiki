package game;

import flixel.graphics.frames.FlxBitmapFont;

class Fonts {
	static var _glasstown:FlxBitmapFont;
	static var _glasstownBold:FlxBitmapFont;

	public static var glasstown(get, never):FlxBitmapFont;
	public static var glasstownBold(get, never):FlxBitmapFont;

	static function get_glasstown():FlxBitmapFont {
		if (_glasstown == null) {
			_glasstown = FlxBitmapFont.fromAngelCode(AssetPaths.glasstown__png, AssetPaths.glasstown__fnt);
		}
		return _glasstown;
	}

	static function get_glasstownBold():FlxBitmapFont {
		if (_glasstownBold == null) {
			_glasstownBold = FlxBitmapFont.fromAngelCode(AssetPaths.glasstown_bold__png, AssetPaths.glasstown_bold__fnt);
		}
		return _glasstownBold;
	}
}
