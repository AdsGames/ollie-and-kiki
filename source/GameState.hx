package;

import flixel.FlxG;
import flixel.FlxState;
import game.World;

class GameState extends FlxState {
	public var world:World;

	override public function create() {
		super.create();

		world = new World(this);
	}
}
