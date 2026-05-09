package game;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxDirectionFlags;
import game.dialogue.DialogueManager;

class Player extends FlxSprite {
	var dialogueManager:DialogueManager;

	public function new(x:Float, y:Float, dialogueManager:DialogueManager) {
		super(x, y, AssetPaths.cat__png);
		this.dialogueManager = dialogueManager;

		// Collision
		width = 6;
		height = 6;

		// Center sprite on tile
		offset.x = 1;
		offset.y = 1;

		allowCollisions = FlxDirectionFlags.ANY;
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		velocity.set(0, 0);

		// Do not move when dialogue is active
		if (dialogueManager.active) {
			return;
		}

		if (FlxG.keys.pressed.UP || FlxG.keys.pressed.W) {
			velocity.y = -60;
		} else if (FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S) {
			velocity.y = 60;
		}
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A) {
			velocity.x = -60;
		} else if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D) {
			velocity.x = 60;
		}
	}
}
