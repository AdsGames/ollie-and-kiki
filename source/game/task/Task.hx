package game.task;

import game.dialogue.DialogueLine;
import game.item.Item;
import game.location.Location;

/**
 * Task state machine:
 * - Delivery/Escort: Idle -> Accepted -> PickedUp -> Delivered
 * - Find/Photo:      Idle -> Accepted -> Delivered (no PickedUp)
 */
class Task {
	public var id:String;

	// Task variant — drives proximity logic and completion flow.
	public var type:TaskType;

	// Optional precursor that must be complete before this can be accepted.
	public var precursorId:Null<String>;

	// Optional set of task ids that lock this one out once they enter or pass
	// in-progress state. Used for branching/exclusive quest lines.
	public var blockedByTasks:Null<Array<String>>;

	public var name:String;
	public var description:String;

	// Item carried for Delivery tasks. Null for Find/Photo/Escort.
	public var item:Null<Item>;

	// Where the task is offered.
	public var giverLocation:Location;

	// Where the carried thing (item or escortee) is picked up. Null for Find/Photo.
	public var from:Null<Location>;

	// Candidate completion targets. Player picks implicitly by reaching one first.
	public var tos:Array<Location>;

	// The recipient the player actually reached. Set on delivery; null until then.
	public var activeTo:Null<Location>;

	// Photo-only: id of the actor whose location must be approached.
	public var targetActorId:Null<String>;

	public var state:TaskState;

	public var timeLimit:Null<Float>;
	public var timeElapsed:Float;
	public var warnPlayed:Bool;

	public var availableAt:Null<Array<String>>;

	public var startLines:Array<DialogueLine>;

	// Default completion lines (used when no recipient-specific lines exist).
	public var completeLines:Array<DialogueLine>;

	// Optional per-recipient overrides keyed by location id.
	public var completeLinesByTo:Map<String, Array<DialogueLine>>;
	public var rewardsByTo:Map<String, Int>;

	// Flat coin reward, used when no per-recipient reward exists. Needed for tasks without an item.
	public var reward:Null<Int>;

	// Escort runtime position, written by EscortFollower, read by TaskManager
	// for completion-proximity checks. Defaults to from-location coords.
	public var escortX:Float;
	public var escortY:Float;

	public function new() {
		this.type = TaskType.Delivery;
		this.state = TaskState.Idle;
		this.precursorId = null;
		this.blockedByTasks = null;
		this.item = null;
		this.from = null;
		this.tos = [];
		this.activeTo = null;
		this.targetActorId = null;
		this.timeLimit = null;
		this.timeElapsed = 0;
		this.warnPlayed = false;
		this.availableAt = null;
		this.reward = null;
		this.escortX = 0;
		this.escortY = 0;

		startLines = [];
		completeLines = [];
		completeLinesByTo = new Map();
		rewardsByTo = new Map();
	}

	public function accept():Void {
		if (state == Idle) {
			state = Accepted;
		}
	}

	public function pickUp():Void {
		if (state == Accepted) {
			state = PickedUp;
			timeElapsed = 0;
			warnPlayed = false;
		}
	}

	/**
	 * Mark the recipient and transition to Delivered.
	 */
	public function deliverAt(to:Location):Void {
		if (state == Accepted || state == PickedUp) {
			activeTo = to;
			state = Delivered;
		}
	}

	public function expire():Void {
		if (state == PickedUp) {
			state = Accepted;
			timeElapsed = 0;
			warnPlayed = false;
		}
	}

	public function update(elapsed:Float):Void {
		if (state == PickedUp && timeLimit != null) {
			timeElapsed += elapsed;
		}
	}

	public function isExpired():Bool {
		return timeLimit != null && state == PickedUp && timeElapsed >= timeLimit;
	}

	public function timeRemaining():Float {
		if (timeLimit == null) {
			return Math.POSITIVE_INFINITY;
		}
		return Math.max(0.0, timeLimit - timeElapsed);
	}

	public function isComplete():Bool {
		return state == Delivered;
	}

	/**
	 * Whether this task occupies a paw slot (carry capacity).
	 */
	public function consumesCarry():Bool {
		return type == Delivery || type == Escort;
	}

	/**
	 * Lines to play on completion, picking recipient-specific lines when available.
	 */
	public function resolveCompleteLines():Array<DialogueLine> {
		if (activeTo != null && completeLinesByTo.exists(activeTo.id)) {
			return completeLinesByTo.get(activeTo.id);
		}
		return completeLines;
	}

	/**
	 * Coin reward for completion. Falls back to the flat reward, then item value, then 0.
	 */
	public function resolveReward():Int {
		if (activeTo != null && rewardsByTo.exists(activeTo.id)) {
			return rewardsByTo.get(activeTo.id);
		}
		if (reward != null) {
			return reward;
		}
		if (item != null) {
			return item.value;
		}
		return 0;
	}
}
