package game.task;

import game.item.ItemManager;
import game.location.Location;
import game.location.LocationManager;
import game.task.Task;
import openfl.Assets;

class TaskManager {
	// Tile-space radius within which the player can interact with a location.
	static final INTERACT_RADIUS = 16.0;

	public var tasks:Array<Task>;
	public var activeTask:Null<Task>;

	var locations:Array<Location>;

	public function new() {
		tasks = [];
		locations = [];
	}

	/**
	 * Load locations then tasks from JSON. Must be called before getActiveTask().
	 * @param itemManager Used to resolve item IDs referenced in tasks.json.
	 * @param locationManager Used to resolve location IDs referenced in tasks.json.
	 */
	public function load(itemManager:ItemManager, locationManager:LocationManager):Void {
		var raw = Assets.getText(AssetPaths.tasks__json);
		var data:Array<{
			var name:String;
			var description:String;
			var itemId:String;
			var fromId:String;
			var toId:String;
		}> = haxe.Json.parse(raw);

		for (entry in data) {
			var item = itemManager.getItemById(entry.itemId);
			var from = locationManager.getLocationById(entry.fromId);
			var to = locationManager.getLocationById(entry.toId);

			if (item != null && from != null && to != null) {
				var task = new Task();
				task.name = entry.name;
				task.description = entry.description;
				task.item = item;
				task.from = from;
				task.to = to;
				tasks.push(task);
			} else {
				trace('Skipping task "${entry.name}": unresolved item or location reference.');
			}
		}

		trace('Loaded ${tasks.length} tasks.');
	}

	/**
	 * Returns the first task that has not yet been delivered, or null if all are done.
	 */
	public function getActiveTask():Null<Task> {
		for (task in tasks) {
			if (!task.isComplete()) {
				return task;
			}
		}
		return null;
	}

	/**
	 * Call this when the player interacts (e.g. presses confirm). Advances the
	 * active task if the player is close enough to the relevant location.
	 * @param playerX Player world-space X.
	 * @param playerY Player world-space Y.
	 * @return True if the task state changed.
	 */
	public function tryInteract(playerX:Float, playerY:Float):Bool {
		var task = getActiveTask();
		if (task == null) {
			return false;
		}

		if (task.state == Idle && isNear(playerX, playerY, task.from)) {
			task.pickUp();
			return true;
		}

		if (task.state == PickedUp && isNear(playerX, playerY, task.to)) {
			task.deliver();
			return true;
		}

		return false;
	}

	inline function isNear(px:Float, py:Float, loc:Location):Bool {
		var dx = px - loc.x;
		var dy = py - loc.y;
		return dx * dx + dy * dy <= INTERACT_RADIUS * INTERACT_RADIUS;
	}
}
