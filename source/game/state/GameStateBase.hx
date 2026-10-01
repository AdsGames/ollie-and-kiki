package game.state;

import game.World;

/**
 * Base class for game states. Subclasses override `enter` / `exit` / `update`.
 * States live on a `GameStateStack`; only the top state's `update` runs each frame.
 */
class GameStateBase {
	private var world:World;

	public function new(world:World) {
		this.world = world;
	}

	public function enter():Void {}

	public function exit():Void {}

	public function update(elapsed:Float):Void {}
}
