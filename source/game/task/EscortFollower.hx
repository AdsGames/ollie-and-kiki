package game.task;

import flixel.FlxSprite;
import game.Player;
import game.actor.Actor;

/**
 * Lightweight follower sprite for Escort tasks. Lerps toward the player
 * while maintaining a small leash, and writes its position back to the
 * task so TaskManager can check completion-proximity.
 */
class EscortFollower extends FlxSprite {
	private static final FOLLOW_SPEED:Float = 60.0;
	private static final LEASH:Float = 14.0;

	public var task:Task;

	private var targetSprite:Player;

	public function new(task:Task, follow:Player, actor:Null<Actor>) {
		super(task.escortX, task.escortY);
		this.task = task;
		this.targetSprite = follow;
		if (actor != null) {
			loadGraphic(actor.image);
		} else {
			makeGraphic(8, 8, 0xFFFFFFFF);
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		// Self-destruct when the task leaves PickedUp (delivered, expired back
		// to Accepted, etc.) so a fresh follower can spawn on re-pickup.
		if (task.state != PickedUp) {
			kill();
			return;
		}

		// Hold still while the player is frozen by a modal (dialogue, pause, store, day summary).
		if (targetSprite.frozen) {
			return;
		}

		var tx = targetSprite.x;
		var ty = targetSprite.y;
		var dx = tx - x;
		var dy = ty - y;
		var dist = Math.sqrt(dx * dx + dy * dy);

		if (dist > LEASH) {
			var step = FOLLOW_SPEED * elapsed;
			if (step > dist - LEASH) {
				step = dist - LEASH;
			}
			x += (dx / dist) * step;
			y += (dy / dist) * step;
		}

		task.escortX = x;
		task.escortY = y;
	}

}
