package game.time;

class TimeController {
	// One full in-game day = 5 real minutes.
	private static final REAL_SECONDS_PER_DAY:Float = 5 * 60;
	private static final GAME_HOURS_PER_DAY:Int = 24;
	private static final MINUTES_PER_HOUR:Int = 60;

	// Game-minutes elapsed per real-second.
	private static final GAME_MINUTES_PER_REAL_SECOND:Float = GAME_HOURS_PER_DAY * MINUTES_PER_HOUR / REAL_SECONDS_PER_DAY;

	// Display clock snaps to multiples of this many in-game minutes.
	private static final DISPLAY_MINUTE_STEP:Int = 10;

	// Game-clock hour at which phase=0 begins. Phase quarters map to 6 AM /
	// noon / 6 PM / midnight, matching the shader's morning/afternoon/evening/night anchors.
	private static final MORNING_START_MINUTE:Int = 6 * 60;

	public var time(default, null):Float;

	// Day number seen by the last checkDayEnded() call.
	private var lastDay:Int;

	public function new() {
		setTime(0);
	}

	public function update(elapsed:Float):Void {
		time += elapsed;
	}

	/** Restore the clock (e.g. from a save) without reporting a day change. */
	public function setTime(value:Float):Void {
		time = value;
		lastDay = getDay();
	}

	/** Current day, starting at 1. A day runs from 6 AM to 6 AM. */
	public function getDay():Int {
		return Std.int(time / REAL_SECONDS_PER_DAY) + 1;
	}

	/** True once each time the clock rolls over into a new day. */
	public function checkDayEnded():Bool {
		var day = getDay();
		if (day > lastDay) {
			lastDay = day;
			return true;
		}
		return false;
	}

	/** Normalized progress through the current day, in [0, 1). 0 = morning start, 0.25 = afternoon, 0.5 = evening, 0.75 = night. */
	public function getPhase():Float {
		return (time % REAL_SECONDS_PER_DAY) / REAL_SECONDS_PER_DAY;
	}

	public function getTimeOfDay():TimeOfDay {
		var p = getPhase();
		if (p < 0.25) {
			return TimeOfDay.Morning;
		} else if (p < 0.5) {
			return TimeOfDay.Afternoon;
		} else if (p < 0.75) {
			return TimeOfDay.Evening;
		} else {
			return TimeOfDay.Night;
		}
	}

	public function getTimeString():String {
		var rawMinutes = Std.int(time * GAME_MINUTES_PER_REAL_SECOND) + MORNING_START_MINUTE;
		var totalGameMinutes = Std.int(rawMinutes / DISPLAY_MINUTE_STEP) * DISPLAY_MINUTE_STEP;
		var hours = Std.int(totalGameMinutes / MINUTES_PER_HOUR) % GAME_HOURS_PER_DAY;
		var minutes = totalGameMinutes % MINUTES_PER_HOUR;
		var ampm = hours < 12 ? "AM" : "PM";
		var displayHours = if (hours == 0) 12 else if (hours > 12) hours - 12 else hours;
		return '${displayHours}:${StringTools.lpad(Std.string(minutes), "0", 2)} ${ampm}';
	}
}
