package game;

import flixel.FlxG;
import flixel.FlxSprite;
import game.dialogue.DialogueLine;
import game.dialogue.DialogueManager;

class Player extends FlxSprite {
	var dialogueManager:DialogueManager;

	public function new(x:Float, y:Float, dialogueManager:DialogueManager) {
		super(x, y, AssetPaths.cat__png);
		this.dialogueManager = dialogueManager;
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		// Do not move when dialogue is active
		if (dialogueManager.active) {
			return;
		}

		if (FlxG.keys.justPressed.Z) {
			dialogueManager.startDialogue([
				new DialogueLine("Ollie", "Hello there!"),
				new DialogueLine("Kiki", "Hi Ollie! How are you?"),
				new DialogueLine("Ollie", "I'm doing great, thanks for asking!"),
			]);
		}

		if (FlxG.keys.pressed.UP) {
			y -= 1;
		} else if (FlxG.keys.pressed.DOWN) {
			y += 1;
		} else if (FlxG.keys.pressed.LEFT) {
			x -= 1;
		} else if (FlxG.keys.pressed.RIGHT) {
			x += 1;
		}
	}
}
