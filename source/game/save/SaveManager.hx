package game.save;

import flixel.FlxG;
import haxe.DynamicAccess;
import game.store.StoreManager;
import game.task.TaskManager;
import game.task.TaskState;
import game.time.DayStats;
import game.time.TimeController;

typedef GameSave = {
	var version:Int;
	var coins:Int;
	var purchased:Array<String>;
	// Task id -> TaskState name. Only non-idle tasks are stored.
	var tasks:DynamicAccess<String>;
	var time:Float;
	var tasksCompletedToday:Int;
	var coinsEarnedToday:Int;
}

/**
 * Persists game progress in the flixel save slot (FlxG.save), next to the
 * volume setting flixel already stores there.
 */
class SaveManager {
	private static final VERSION:Int = 1;

	public static function hasSave():Bool {
		var data:Null<GameSave> = FlxG.save.data.game;
		return data != null && data.version == VERSION;
	}

	public static function clear():Void {
		FlxG.save.data.game = null;
		FlxG.save.flush();
	}

	public static function save(store:StoreManager, tasks:TaskManager, time:TimeController, stats:DayStats):Void {
		var taskStates = new DynamicAccess<String>();
		for (task in tasks.tasks) {
			if (task.state != Idle) {
				taskStates.set(task.id, Std.string(task.state));
			}
		}

		var data:GameSave = {
			version: VERSION,
			coins: store.coins,
			purchased: store.getAllPurchased(),
			tasks: taskStates,
			time: time.time,
			tasksCompletedToday: stats.tasksCompleted,
			coinsEarnedToday: stats.coinsEarned,
		};
		FlxG.save.data.game = data;
		FlxG.save.flush();
	}

	/**
	 * Apply the saved game to freshly loaded managers.
	 * @return True if a save was loaded.
	 */
	public static function load(store:StoreManager, tasks:TaskManager, time:TimeController, stats:DayStats):Bool {
		if (!hasSave()) {
			return false;
		}
		var data:GameSave = FlxG.save.data.game;

		store.restore(data.coins, data.purchased);

		var states = new Map<String, TaskState>();
		for (id => name in data.tasks) {
			var state = parseState(name);
			if (state != null) {
				states.set(id, state);
			}
		}
		tasks.restoreStates(states);

		time.setTime(data.time);
		stats.tasksCompleted = data.tasksCompletedToday;
		stats.coinsEarned = data.coinsEarnedToday;
		return true;
	}

	private static function parseState(name:String):Null<TaskState> {
		return switch (name) {
			case "Accepted": Accepted;
			// Carried items and escorts are not restored mid-trip; the task restarts from pickup.
			case "PickedUp": Accepted;
			case "Delivered": Delivered;
			default: null;
		}
	}
}
