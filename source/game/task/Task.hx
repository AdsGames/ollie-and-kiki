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
	public var from:Location;
	public var to:Location;
	public var state:TaskState = TaskState.Idle;

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

	/**
	 * Checks if the task is complete (i.e., item has been delivered).
	 * @return True if the task is complete, false otherwise.
	 */
	public function isComplete():Bool {
		return state == Delivered;
	}
}
