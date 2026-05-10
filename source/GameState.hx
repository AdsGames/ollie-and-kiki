package;

import flixel.FlxState;
import game.World;

class GameState extends FlxState {
	// The game world instance.
	public var world:World;

	override public function create():Void {
		super.create();
		world = new World(this);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		world.update(elapsed);
	}
}
