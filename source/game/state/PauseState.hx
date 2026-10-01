package game.state;

import game.World;

/**
 * Modal: the pause menu is open. PauseMenu is a FlxGroup that self-updates via
 * Flixel, so this state has nothing to tick - it exists to freeze the world.
 */
class PauseState extends GameStateBase {
	public function new(world:World) {
		super(world);
	}
}
