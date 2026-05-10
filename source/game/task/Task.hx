package game.task;

import game.dialogue.DialogueLine;
import game.item.Item;
import game.location.Location;
import game.task.TaskState;

/**
 * Task state machine:
 * Idle -> Accepted -> PickedUp -> Delivered
 */
class Task {
	public var name:String;
	public var description:String;

	public var item:Item;
	public var giverLocation:Location;
	public var from:Location;
	public var to:Location;
	public var state:TaskState = TaskState.Idle;

	/** Seconds allowed between PickedUp and Delivered. Null means no limit. */
	public var timeLimit:Null<Float> = null;

	public var timeElapsed:Float = 0;
	public var warnPlayed:Bool = false;

	public var startLines:Array<DialogueLine>;
	public var completeLines:Array<DialogueLine>;

	public function new() {
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
