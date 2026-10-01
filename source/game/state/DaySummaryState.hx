package game.state;

import game.World;

/**
 * Modal: the end-of-day summary is shown. DaySummary self-updates via Flixel,
 * so this state has nothing to tick - it exists to freeze the world.
 */
class DaySummaryState extends GameStateBase {
	public function new(world:World) {
		super(world);
	}
}
