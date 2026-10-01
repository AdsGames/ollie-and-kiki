package game.state;

import game.World;

/**
 * Modal: the store UI is open. StoreUI is a FlxGroup that self-updates via
 * Flixel, so this state has nothing to tick - it exists to gate everything else.
 */
class StoreState extends GameStateBase {
	public function new(world:World) {
		super(world);
	}
}
