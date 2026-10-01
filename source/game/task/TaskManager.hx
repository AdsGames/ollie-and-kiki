package game.task;

import game.actor.ActorManager;
import game.dialogue.DialogueLine;
import game.event.EventBus;
import game.item.ItemManager;
import game.location.Location;
import game.location.LocationManager;
import game.store.StoreManager;
import game.time.TimeController;
import openfl.Assets;

class TaskManager {
	// Tile-space radius within which the player can interact with a location.
	private static final INTERACT_RADIUS:Float = 16.0;

	private static final INTERACT_RADIUS_SQ:Float = INTERACT_RADIUS * INTERACT_RADIUS;

	private static final TIMER_WARN_THRESHOLD:Float = 10.0;

	public var tasks:Array<Task>;

	public var storeManager:StoreManager;

	private var events:EventBus;
	private var timeController:TimeController;
	private var actorManager:Null<ActorManager>;
	private var locationManager:Null<LocationManager>;

	public function new(storeManager:StoreManager, events:EventBus, timeController:TimeController) {
		this.storeManager = storeManager;
		this.events = events;
		this.timeController = timeController;
		tasks = [];
	}

	public function load(itemManager:ItemManager, locationManager:LocationManager, ?actorManager:ActorManager):Void {
		this.locationManager = locationManager;
		this.actorManager = actorManager;

		var raw = Assets.getText(AssetPaths.tasks__json);
		var data:Array<Dynamic> = haxe.Json.parse(raw);

		for (entry in data) {
			var task = parseTask(entry, itemManager, locationManager);
			if (task != null) {
				tasks.push(task);
			}
		}

		trace('Loaded ${tasks.length} tasks.');
	}

	/**
	 * Restore task states from a save, keyed by task id. Emits no events.
	 */
	public function restoreStates(states:Map<String, TaskState>):Void {
		for (task in tasks) {
			var state = states.get(task.id);
			if (state != null) {
				task.state = state;
			}
		}
	}

	private function parseTask(entry:Dynamic, itemManager:ItemManager, locationManager:LocationManager):Null<Task> {
		var task = new Task();
		task.id = entry.id;
		task.name = entry.name;
		task.description = entry.description;
		task.precursorId = entry.precursorId;
		task.blockedByTasks = entry.blockedByTasks;
		task.timeLimit = entry.timeLimit;
		task.availableAt = entry.availableAt;
		task.targetActorId = entry.targetActorId;
		task.reward = entry.reward;

		task.type = parseType(entry.type);

		var giver = locationManager.getLocationById(entry.giverLocationId);
		if (giver == null) {
			trace('Skipping task "${task.name}": unknown giver "${entry.giverLocationId}".');
			return null;
		}
		task.giverLocation = giver;

		if (entry.itemId != null) {
			task.item = itemManager.getItemById(entry.itemId);
		}
		if (task.type == Delivery && task.item == null) {
			trace('Skipping delivery "${task.name}": item "${entry.itemId}" not found.');
			return null;
		}

		if (entry.fromId != null) {
			task.from = locationManager.getLocationById(entry.fromId);
		}
		if ((task.type == Delivery || task.type == Escort) && task.from == null) {
			trace('Skipping ${task.type} "${task.name}": missing "from".');
			return null;
		}

		var toIds:Array<String> = entry.toIds;
		if (toIds != null) {
			for (id in toIds) {
				var loc = locationManager.getLocationById(id);
				if (loc != null) {
					task.tos.push(loc);
				}
			}
		}
		if (task.type != Photo && task.tos.length == 0) {
			trace('Skipping "${task.name}": no valid destinations.');
			return null;
		}

		// Conversation: required start; complete may be a flat array (legacy/default)
		// or a map of locationId -> { lines, reward? }.
		if (entry.conversation != null) {
			var start:Array<Dynamic> = entry.conversation.start;
			if (start != null) {
				task.startLines = [for (e in start) new DialogueLine(e.actor, e.text)];
			}

			var complete:Dynamic = entry.conversation.complete;
			if (Std.isOfType(complete, Array)) {
				var arr:Array<Dynamic> = cast complete;
				task.completeLines = [for (e in arr) new DialogueLine(e.actor, e.text)];
			} else if (complete != null) {
				for (locId in Reflect.fields(complete)) {
					var branch = Reflect.field(complete, locId);
					var lines:Array<Dynamic> = branch.lines;
					if (lines != null) {
						task.completeLinesByTo.set(locId, [for (e in lines) new DialogueLine(e.actor, e.text)]);
					}
					if (branch.reward != null) {
						task.rewardsByTo.set(locId, branch.reward);
					}
				}
			}
		}

		return task;
	}

	private function parseType(s:Null<String>):TaskType {
		if (s == null) {
			return Delivery;
		}
		return switch s.toLowerCase() {
			case "find": Find;
			case "photo": Photo;
			case "escort": Escort;
			default: Delivery;
		}
	}

	public function getIdleTaskNearGiver(playerX:Float, playerY:Float):Null<Task> {
		for (task in tasks) {
			if (!canActivate(task)) {
				continue;
			}
			var giverActor = actorManager != null ? actorManager.getActorForLocation(task.giverLocation.id) : null;
			var near = giverActor != null ? isNear(playerX, playerY, giverActor.x, giverActor.y) : isNearLoc(playerX, playerY, task.giverLocation);
			if (near) {
				return task;
			}
		}
		return null;
	}

	public function canActivate(task:Task):Bool {
		return task.state == Idle
			&& isPrecursorComplete(task)
			&& !isBlocked(task)
			&& !actorHasActiveTask(task.giverLocation.id)
			&& matchesTimeOfDay(task);
	}

	private function matchesTimeOfDay(task:Task):Bool {
		if (task.availableAt == null) {
			return true;
		}
		var current = Type.enumConstructor(timeController.getTimeOfDay());
		for (slot in task.availableAt) {
			if (slot == current) {
				return true;
			}
		}
		return false;
	}

	/**
	 * Advance per-type proximity transitions. Emits TaskPickedUp / TaskDelivered.
	 * Photo tasks never auto-complete here — they require tryPhotoSnap().
	 */
	public function updateProximity(playerX:Float, playerY:Float):Void {
		for (task in tasks) {
			switch task.type {
				case Delivery:
					stepDelivery(task, playerX, playerY);
				case Escort:
					stepEscort(task, playerX, playerY);
				case Find:
					stepFind(task, playerX, playerY);
				case Photo:
					// no-op — handled by tryPhotoSnap
			}
		}
	}

	private function stepDelivery(task:Task, px:Float, py:Float):Void {
		if (task.state == Accepted && task.from != null && isNearLoc(px, py, task.from)) {
			task.pickUp();
			events.emit(TaskPickedUp(task));
		} else if (task.state == PickedUp) {
			var to = findReachedRecipient(task, px, py);
			if (to != null) {
				task.deliverAt(to);
				events.emit(TaskDelivered(task));
			}
		}
	}

	private function stepEscort(task:Task, px:Float, py:Float):Void {
		if (task.state == Accepted && task.from != null && isNearLoc(px, py, task.from)) {
			task.escortX = task.from.x;
			task.escortY = task.from.y;
			task.pickUp();
			events.emit(TaskPickedUp(task));
		} else if (task.state == PickedUp) {
			var to = findReachedRecipient(task, px, py);
			if (to != null && isNear(task.escortX, task.escortY, to.x, to.y)) {
				task.deliverAt(to);
				events.emit(TaskDelivered(task));
			}
		}
	}

	/**
	 * True if an Escort task is currently in progress whose escortee normally
	 * lives at `locationId`. Used to hide that actor at home while following.
	 */
	public function isLocationActorEscorting(locationId:String):Bool {
		for (task in tasks) {
			if (task.type == Escort && task.state == PickedUp && task.from != null && task.from.id == locationId) {
				return true;
			}
		}
		return false;
	}

	private function stepFind(task:Task, px:Float, py:Float):Void {
		if (task.state == Accepted) {
			var to = findReachedRecipient(task, px, py);
			if (to != null) {
				task.deliverAt(to);
				events.emit(TaskDelivered(task));
			}
		}
	}

	/**
	 * Player pressed the Photo key. Completes the first photo task whose
	 * target actor is in range and whose time-of-day window matches.
	 */
	public function tryPhotoSnap(px:Float, py:Float):Bool {
		var task = findPhotoTask(px, py);
		if (task == null) {
			return false;
		}
		task.deliverAt(photoTargetLocation(task));
		events.emit(TaskDelivered(task));
		return true;
	}

	/**
	 * First accepted photo task whose target is in range right now, or null.
	 */
	public function findPhotoTask(px:Float, py:Float):Null<Task> {
		for (task in tasks) {
			if (task.type != Photo || task.state != Accepted) {
				continue;
			}
			if (!matchesTimeOfDay(task)) {
				continue;
			}
			var target = photoTargetLocation(task);
			if (target != null && isNearLoc(px, py, target)) {
				return task;
			}
		}
		return null;
	}

	public function photoTargetLocation(task:Task):Null<Location> {
		if (task.targetActorId != null && actorManager != null && locationManager != null) {
			var actor = actorManager.getActorById(task.targetActorId);
			if (actor != null && actor.locationId != null) {
				var loc = locationManager.getLocationById(actor.locationId);
				if (loc != null) {
					return loc;
				}
			}
		}
		return task.tos.length > 0 ? task.tos[0] : null;
	}

	/**
	 * Primary destination for the quest arrow / map marker — uses the
	 * activeTo if locked in, otherwise the first candidate.
	 */
	public function primaryDestination(task:Task):Null<Location> {
		if (task.activeTo != null) {
			return task.activeTo;
		}
		if (task.type == Photo) {
			return photoTargetLocation(task);
		}
		return task.tos.length > 0 ? task.tos[0] : null;
	}

	public function isCarryFull():Bool {
		return countCarried() >= maxCarried();
	}

	public function updateTimers(elapsed:Float):Void {
		for (task in tasks) {
			task.update(elapsed);
			if (task.isExpired()) {
				task.expire();
				events.emit(TaskExpired(task));
			} else if (!task.warnPlayed
				&& task.timeLimit != null
				&& task.state == PickedUp
				&& task.timeRemaining() <= TIMER_WARN_THRESHOLD) {
				task.warnPlayed = true;
				events.emit(TaskTimerWarned(task));
			}
		}
	}

	private function findReachedRecipient(task:Task, px:Float, py:Float):Null<Location> {
		for (loc in task.tos) {
			if (isNearLoc(px, py, loc)) {
				return loc;
			}
		}
		return null;
	}

	private inline function isNearLoc(px:Float, py:Float, loc:Location):Bool {
		return isNear(px, py, loc.x, loc.y);
	}

	private inline function isNear(ax:Float, ay:Float, bx:Float, by:Float):Bool {
		var dx = ax - bx;
		var dy = ay - by;
		return dx * dx + dy * dy <= INTERACT_RADIUS_SQ;
	}

	private function maxCarried():Int {
		return 1 + storeManager.totalCarryBonus();
	}

	private inline function isInProgress(task:Task):Bool {
		return task.state == Accepted || task.state == PickedUp;
	}

	private function actorHasActiveTask(actorId:String):Bool {
		for (task in tasks) {
			if (isInProgress(task) && task.giverLocation.id == actorId) {
				return true;
			}
		}
		return false;
	}

	private function isPrecursorComplete(task:Task):Bool {
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
	 * A task is blocked once any of its declared rivals has been accepted or
	 * completed — the player committed to the other branch.
	 */
	private function isBlocked(task:Task):Bool {
		if (task.blockedByTasks == null) {
			return false;
		}
		for (otherId in task.blockedByTasks) {
			for (t in tasks) {
				if (t.id == otherId && t.state != Idle) {
					return true;
				}
			}
		}
		return false;
	}

	private function countCarried():Int {
		var count = 0;
		for (task in tasks) {
			if (task.consumesCarry() && isInProgress(task)) {
				count++;
			}
		}
		return count;
	}
}
