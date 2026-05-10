package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.sound.FlxSound;
import game.World;

class GameState extends FlxState {
	public var world:World;

	override public function create() {
		super.create();
		world = new World(this);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		world.update(elapsed);
	}
}
