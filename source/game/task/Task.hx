package game.task;

import game.dialogue.DialogueLine;
import game.item.Item;
import game.location.Location;

/**
 * Task state machine:
 * Idle -> Accepted -> PickedUp -> Delivered
 */
class Task {
	// Unique identifier for the task, used for saving/loading and referencing in dialogue.
	public var id:String;

	// Optional identifier of a precursor task that must be completed before this one can be accepted.
	public var precursorId:Null<String>;

	// Display name and description for the task.
	public var name:String;

	// Description shown in the task list and dialogue.
	public var description:String;

	// The item associated with the task.
	public var item:Item;

	// The location where the task is given.
	public var giverLocation:Location;

	// The location where the item is picked up.
	public var from:Location;

	// The location where the item is delivered.
	public var to:Location;

	// The current state of the task.
	public var state:TaskState;

	// Seconds allowed between PickedUp and Delivered. Null means no limit.
	public var timeLimit:Null<Float>;

	// Time elapsed since the task was picked up. Only relevant if timeLimit is not null.
	public var timeElapsed:Float;

	// Whether the warning sound has been played for this task (when time is running out).
	public var warnPlayed:Bool;

	// Dialogue lines to show when the task is accepted and completed.
	public var startLines:Array<DialogueLine>;

	// Dialogue lines to show when the task is completed.
	public var completeLines:Array<DialogueLine>;

	public function new() {
		this.state = TaskState.Idle;
		this.precursorId = null;
		this.timeLimit = null;
		this.timeElapsed = 0;
		this.warnPlayed = false;

		startLines = [];
		completeLines = [];
	}

	/**
	 * Player accepts the task — enables proximity tracking to `from`.
	 */
	public function accept():Void {
		if (state == Idle) {
			state = Accepted;
		}
	}

	/**
	 * Player is at `from` and interacts — pick up the item.
	 */
	public function pickUp():Void {
		if (state == Accepted) {
			state = PickedUp;
			timeElapsed = 0;
			warnPlayed = false;
		}
	}

	/**
	 * Player is at `to` and interacts — deliver the item.
	 */
	public function deliver():Void {
		if (state == PickedUp) {
			state = Delivered;
		}
	}

	/** Time ran out */
	public function expire():Void {
		if (state == PickedUp) {
			state = Accepted;
			timeElapsed = 0;
			warnPlayed = false;
		}
	}

	/** Tick the delivery timer forward */
	public function update(elapsed:Float):Void {
		if (state == PickedUp && timeLimit != null) {
			timeElapsed += elapsed;
		}
	}

	/**
	 * Checks if the task is expired
	 * @return True if the task is expired, false otherwise.
	 */
	public function isExpired():Bool {
		return timeLimit != null && state == PickedUp && timeElapsed >= timeLimit;
	}

	public function timeRemaining():Float {
		if (timeLimit == null) {
			return Math.POSITIVE_INFINITY;
		}
		return Math.max(0.0, timeLimit - timeElapsed);
	}

	/**
	 * Checks if the task is complete (i.e., item has been delivered).
	 * @return True if the task is complete, false otherwise.
	 */
	public function isComplete():Bool {
		return state == Delivered;
	}
}
