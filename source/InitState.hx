package;

import flixel.FlxG;
import flixel.FlxGame;

class InitState extends FlxGame {
	public function new() {
		super(240, 160, MenuState, 60, 60, true, false);
		FlxG.sound.volume = 1.0;
		FlxG.mouse.useSystemCursor = true;
	}
}
