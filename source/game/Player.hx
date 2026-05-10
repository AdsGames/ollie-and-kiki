package game;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxDirectionFlags;
import game.dialogue.DialogueManager;
import game.store.StoreManager;

class Player extends FlxSprite {
	var dialogueManager:DialogueManager;
	var storeManager:StoreManager;

	public function new(x:Float, y:Float, dialogueManager:DialogueManager, storeManager:StoreManager) {
		super(x, y, AssetPaths.cat__png);
		this.dialogueManager = dialogueManager;
		this.storeManager = storeManager;

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

		// Do not move when dialogue or store UI is active
		if (dialogueManager.active || storeManager.isOpen) {
			return;
		}

		// Calculate speed
		var speed = 60.0;
		if (storeManager.isPurchased("running_shoes")) {
			speed = 100.0;
		}

		if (FlxG.keys.pressed.UP || FlxG.keys.pressed.W) {
			velocity.y = -speed;
		} else if (FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S) {
			velocity.y = speed;
		}
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A) {
			velocity.x = -speed;
		} else if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D) {
			velocity.x = speed;
		}
	}

	override public function draw() {
		super.draw();

		// Overlay items
		for (itemId in storeManager.getAllPurchased()) {
			var overlay = storeManager.getOverlay(itemId);
			if (overlay != null) {
				drawItem(overlay);
			}
		}
	}

	private function drawItem(overlay:FlxSprite) {
		overlay.x = x - offset.x;
		overlay.y = y - offset.y;
		overlay.draw();
	}
}
