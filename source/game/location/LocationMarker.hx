package game.location;

import flixel.FlxG;
import flixel.FlxSprite;

class LocationMarker extends FlxSprite {
	public var location:Location;

	public function new(location:Location) {
		super(location.x, location.y, AssetPaths.marker__png);
		this.location = location;
		scrollFactor.set(1, 1);
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		// Animation
		var animTime = FlxG.game.ticks / 100;
		var yOff = 1 + 2 * Math.sin(animTime);
		y = location.y + yOff;
	}
}
