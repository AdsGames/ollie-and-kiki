package game.time;

/**
 * Running totals for the current in-game day. Reset when a new day starts.
 */
class DayStats {
	public var tasksCompleted:Int;
	public var coinsEarned:Int;

	public function new() {
		reset();
	}

	public function reset():Void {
		tasksCompleted = 0;
		coinsEarned = 0;
	}
}
