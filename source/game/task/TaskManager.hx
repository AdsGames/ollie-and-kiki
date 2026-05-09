package game.task;

import game.dialogue.DialogueLine;
import game.item.ItemManager;
import game.location.Location;
import game.location.LocationManager;
import game.task.Task;
import openfl.Assets;

class TaskManager {
	/** Tile-space radius within which the player can interact with a location. */
	static final INTERACT_RADIUS = 16.0;

	public var tasks:Array<Task>;

	public function new() {
		tasks = [];
	}

	/**
	 * Load tasks from JSON, resolving items, locations, and actor portraits.
	 */
	public function load(itemManager:ItemManager, locationManager:LocationManager):Void {
		var raw = Assets.getText(AssetPaths.tasks__json);
		var data:Array<{
			name:String,
			description:String,
			itemId:String,
			fromId:String,
			toId:String,
			conversation:{start:Array<{actor:String, text:String}>, complete:Array<{actor:String, text:String}>}
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
				task.startLines = entry.conversation.start.map(entry -> new DialogueLine(entry.actor, entry.text));
				task.completeLines = entry.conversation.complete.map(entry -> new DialogueLine(entry.actor, entry.text));
				tasks.push(task);
			} else {
				trace('Skipping task "${entry.name}": unresolved item or location reference.');
			}
		}

		trace('Loaded ${tasks.length} tasks.');
	}

	/**
	 * Returns the first incomplete task, or null if all are done.
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
	 * Called when the player presses the accept key.
	 */
	public function acceptActiveTask():Null<Task> {
		var task = getActiveTask();
		if (task != null && task.state == Idle) {
			task.accept();
			return task;
		}
		return null;
	}

	/**
	 * Call every frame (only when dialogue is not active). Advances task state based on
	 * proximity and returns the complete dialogue lines when the task is delivered,
	 * otherwise null.
	 * @param playerX Player world-space X.
	 * @param playerY Player world-space Y.
	 */
	public function updateProximity(playerX:Float, playerY:Float):Null<Array<DialogueLine>> {
		var task = getActiveTask();
		if (task == null) {
			return null;
		}

		if (task.state == Accepted && isNear(playerX, playerY, task.from)) {
			task.pickUp();
		} else if (task.state == PickedUp && isNear(playerX, playerY, task.to)) {
			task.deliver();
			return task.completeLines;
		}

		return null;
	}

	inline function isNear(px:Float, py:Float, loc:Location):Bool {
		var dx = px - loc.x;
		var dy = py - loc.y;
		return dx * dx + dy * dy <= INTERACT_RADIUS * INTERACT_RADIUS;
	}
}
