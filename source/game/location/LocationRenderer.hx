package game.location;

import flixel.FlxSprite;

class LocationRenderer extends FlxSprite {
	public var location:Location;

	public function new(location:Location) {
		super(location.x, location.y, AssetPaths.marker__png);
		this.location = location;
	}
}
