package game;

import flixel.FlxSprite;
import flixel.util.FlxDirectionFlags;
import game.store.StoreManager;

class Player extends FlxSprite {
	private var storeManager:StoreManager;

	/** Set externally (by World event subscriptions) to gate movement during modal screens. */
	public var frozen:Bool;

	public function new(x:Float, y:Float, storeManager:StoreManager) {
		super(x, y, AssetPaths.cat__png);
		this.storeManager = storeManager;
		this.frozen = false;

		// Collision
		width = 6;
		height = 6;

		// Center sprite on tile
		offset.x = 1;
		offset.y = 1;

		allowCollisions = FlxDirectionFlags.ANY;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		velocity.set(0, 0);

		if (frozen) {
			return;
		}

		// Calculate speed
		var speed = 60.0;
		if (storeManager.isPurchased("running_shoes")) {
			speed = 100.0;
		}

		if (InputManager.pressed(MoveUp)) {
			velocity.y = -speed;
		} else if (InputManager.pressed(MoveDown)) {
			velocity.y = speed;
		}
		if (InputManager.pressed(MoveLeft)) {
			velocity.x = -speed;
		} else if (InputManager.pressed(MoveRight)) {
			velocity.x = speed;
		}
	}

	override public function draw():Void {
		super.draw();

		// Overlay items
		for (itemId in storeManager.getAllPurchased()) {
			var overlay = storeManager.getOverlay(itemId);
			if (overlay != null) {
				drawItem(overlay);
			}
		}
	}

	private function drawItem(overlay:FlxSprite):Void {
		overlay.x = x - offset.x;
		overlay.y = y - offset.y;
		overlay.draw();
	}
}
