package game;

import flixel.graphics.frames.FlxBitmapFont;

class Fonts {
	private static var _glasstown:FlxBitmapFont;
	private static var _glasstownBold:FlxBitmapFont;

	// The standard Glasstown bitmap font.
	public static var glasstown(get, never):FlxBitmapFont;

	// The bold Glasstown bitmap font.
	public static var glasstownBold(get, never):FlxBitmapFont;

	private static function get_glasstown():FlxBitmapFont {
		if (_glasstown == null) {
			_glasstown = FlxBitmapFont.fromAngelCode(AssetPaths.glasstown__png, AssetPaths.glasstown__fnt);
		}
		return _glasstown;
	}

	private static function get_glasstownBold():FlxBitmapFont {
		if (_glasstownBold == null) {
			_glasstownBold = FlxBitmapFont.fromAngelCode(AssetPaths.glasstown_bold__png, AssetPaths.glasstown_bold__fnt);
		}
		return _glasstownBold;
	}
}
