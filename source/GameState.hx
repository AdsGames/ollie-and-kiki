package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;
import game.World;

class GameState extends FlxState {
	// The game world instance.
	public var world:World;

	override public function create():Void {
		super.create();
		world = new World(this);
		FlxG.camera.fade(FlxColor.BLACK, 0.4, true);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		world.update(elapsed);
	}
}
