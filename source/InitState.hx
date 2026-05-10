package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import openfl.display.StageQuality;

class InitState extends FlxGame {
	public function new() {
		super(240, 160, MenuState, 60, 60, true, false);
		FlxG.sound.volume = 1.0;
		FlxG.mouse.useSystemCursor = true;
	}

	override function create(_):Void {
		super.create(_);
		stage.quality = StageQuality.LOW;
		FlxSprite.defaultAntialiasing = false;
		FlxG.sound.playMusic(AssetPaths.jazzollie__ogg, 0.6, true);
	}
}
