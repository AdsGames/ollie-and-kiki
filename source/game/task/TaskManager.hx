package game.task;

import game.dialogue.DialogueLine;
import game.item.ItemManager;
import game.location.Location;
import game.location.LocationManager;
import game.store.StoreManager;
import game.task.Task;
import openfl.Assets;

class TaskManager {
	/** Tile-space radius within which the player can interact with a location. */
	static final INTERACT_RADIUS = 16.0;

	/** Seconds remaining at which the timer warning sound fires. */
	static final TIMER_WARN_THRESHOLD = 10.0;

	public var tasks:Array<Task>;

	// Store manager reference
	public var storeManager:StoreManager;

	public function new(storeManager:StoreManager) {
		this.storeManager = storeManager;
		tasks = [];
	}

	/**
	 * Load tasks from JSON, resolving items, locations, and actor portraits.
	 */
	public function load(itemManager:ItemManager, locationManager:LocationManager):Void {
		var raw = Assets.getText(AssetPaths.tasks__json);
		var data:Array<{
			id:String,
			?precursorId:String,
			name:String,
			description:String,
			itemId:String,
			giverLocationId:String,
			fromId:String,
			toId:String,
			?timeLimit:Float,
			conversation:{
				start:Array<{actor:String, text:String}>,
				complete:Array<{actor:String, text:String}>
			}
		}> = haxe.Json.parse(raw);

		for (entry in data) {
			var item = itemManager.getItemById(entry.itemId);
			var giver = locationManager.getLocationById(entry.giverLocationId);
			var from = locationManager.getLocationById(entry.fromId);
			var to = locationManager.getLocationById(entry.toId);

			if (item != null && giver != null && from != null && to != null) {
				var task = new Task();
				task.id = entry.id;
				task.precursorId = entry.precursorId;
				task.name = entry.name;
				task.description = entry.description;
				task.item = item;
				task.giverLocation = giver;
				task.from = from;
				task.to = to;
				task.timeLimit = entry.timeLimit;
				task.startLines = [for (e in entry.conversation.start) new DialogueLine(e.actor, e.text)];
				task.completeLines = [for (e in entry.conversation.complete) new DialogueLine(e.actor, e.text)];
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
		for (task in tasks) {
			if (task.state == Idle && isNear(playerX, playerY, task.giverLocation) && isPrecursorComplete(task)) {
				return task;
			}
		}
		return null;
	}

	public function isPrecursorComplete(task:Task):Bool {
		if (task.precursorId == null) {
			return true;
		}
		for (t in tasks) {
			if (t.id == task.precursorId) {
				return t.isComplete();
			}
		}
		return false;
	}

	/**
	 * Call every frame (only when dialogue is not active). Advances task state for ALL
	 * active tasks based on proximity. Returns the first pickup and delivery events this frame.
	 */
	public function updateProximity(playerX:Float, playerY:Float):{pickedUp:Null<Task>, delivered:Null<Task>} {
		var pickedUp:Null<Task> = null;
		var delivered:Null<Task> = null;

		for (task in tasks) {
			if (task.state == Accepted && isNear(playerX, playerY, task.from)) {
				task.pickUp();
				if (pickedUp == null) {
					pickedUp = task;
				}
			} else if (task.state == PickedUp && isNear(playerX, playerY, task.to)) {
				task.deliver();
				if (delivered == null) {
					delivered = task;
				}
			}
		}
		return {pickedUp: pickedUp, delivered: delivered};
	}

	public function isCarryFull():Bool {
		return countInProgress() >= maxCarried();
	}

	/**
	 * Tick all task timers, expire overdue tasks, and flag the first task that
	 * just crossed the warning threshold this frame.
	 */
	public function updateTimers(elapsed:Float):{expired:Null<Task>, warned:Null<Task>} {
		var expired:Null<Task> = null;
		var warned:Null<Task> = null;
		for (task in tasks) {
			task.update(elapsed);
			if (task.isExpired()) {
				task.expire();
				if (expired == null) {
					expired = task;
				}
			} else if (!task.warnPlayed
				&& task.timeLimit != null
				&& task.state == PickedUp
				&& task.timeRemaining() <= TIMER_WARN_THRESHOLD) {
				task.warnPlayed = true;
				if (warned == null) {
					warned = task;
				}
			}
		}
		return {expired: expired, warned: warned};
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

	private function maxCarried():Int {
		var max = 1;
		if (storeManager.isPurchased("backpack")) {
			max = 3;
		}
		return max;
	}
}
