package game;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxSprite;

class Player extends FlxSprite {
	public function new(x:Float, y:Float) {
		super(x, y);
	}

	// Update player logic here
	override public function update(elapsed:Float) {
		super.update(elapsed);

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
