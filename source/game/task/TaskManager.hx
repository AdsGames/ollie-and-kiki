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

	/** Maximum number of tasks the player can have in progress at once. */
	static final MAX_IN_PROGRESS = 3;

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
			giverLocationId:String,
			fromId:String,
			toId:String,
			conversation:{start:Array<{actor:String, text:String}>, complete:Array<{actor:String, text:String}>}
		}> = haxe.Json.parse(raw);

		for (entry in data) {
			var item = itemManager.getItemById(entry.itemId);
			var giver = locationManager.getLocationById(entry.giverLocationId);
			var from = locationManager.getLocationById(entry.fromId);
			var to = locationManager.getLocationById(entry.toId);

			if (item != null && giver != null && from != null && to != null) {
				var task = new Task();
				task.name = entry.name;
				task.description = entry.description;
				task.item = item;
				task.giverLocation = giver;
				task.from = from;
				task.to = to;
				task.startLines = [for (e in entry.conversation.start) for (l in splitText(e.actor, e.text)) l];
				task.completeLines = [for (e in entry.conversation.complete) for (l in splitText(e.actor, e.text)) l];
				tasks.push(task);
			} else {
				trace('Skipping task "${entry.name}": unresolved item or location reference.');
			}
		}

		trace('Loaded ${tasks.length} tasks.');
	}

	/**
	 * Returns an idle task whose giver location is near the player, if the player
	 * has fewer than MAX_IN_PROGRESS tasks already active. Returns null otherwise.
	 */
	public function getIdleTaskNearGiver(playerX:Float, playerY:Float):Null<Task> {
		if (countInProgress() >= MAX_IN_PROGRESS) {
			return null;
		}
		for (task in tasks) {
			if (task.state == Idle && isNear(playerX, playerY, task.giverLocation)) {
				return task;
			}
		}
		return null;
	}

	/**
	 * Call every frame (only when dialogue is not active). Advances task state for ALL
	 * active tasks based on proximity. Returns the completion dialogue of the first task
	 * that gets delivered this frame, or null.
	 */
	public function updateProximity(playerX:Float, playerY:Float):Null<Array<DialogueLine>> {
		var deliveredLines:Null<Array<DialogueLine>> = null;
		for (task in tasks) {
			if (task.state == Accepted && isNear(playerX, playerY, task.from)) {
				task.pickUp();
			} else if (task.state == PickedUp && isNear(playerX, playerY, task.to)) {
				task.deliver();
				if (deliveredLines == null) {
					deliveredLines = task.completeLines;
				}
			}
		}
		return deliveredLines;
	}

	function countInProgress():Int {
		var count = 0;
		for (task in tasks) {
			if (task.state == Accepted || task.state == PickedUp) {
				count++;
			}
		}
		return count;
	}

	inline function isNear(px:Float, py:Float, loc:Location):Bool {
		var dx = px - loc.x;
		var dy = py - loc.y;
		return dx * dx + dy * dy <= INTERACT_RADIUS * INTERACT_RADIUS;
	}

	static function splitText(actorId:String, text:String):Array<DialogueLine> {
		final MAX_CHARS = 70;
		if (text.length <= MAX_CHARS) {
			return [new DialogueLine(actorId, text)];
		}
		var lines:Array<DialogueLine> = [];
		var current = "";
		for (word in text.split(" ")) {
			var candidate = current.length == 0 ? word : current + " " + word;
			if (candidate.length > MAX_CHARS) {
				if (current.length > 0) {
					lines.push(new DialogueLine(actorId, current));
				}
				current = word;
			} else {
				current = candidate;
			}
		}
		if (current.length > 0) {
			lines.push(new DialogueLine(actorId, current));
		}
		return lines;
	}
}
