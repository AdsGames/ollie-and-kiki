package game.location;

import flixel.FlxSprite;
import flixel.group.FlxGroup;

class LocationRenderer extends FlxGroup {
	private var markers:Array<LocationMarker>;

	public function new() {
		super();
	}

	public function setLocations(locations:Array<Location>):Void {
		clear();
		markers = [];
		for (location in locations) {
			var marker = new LocationMarker(location);
			add(marker);
			markers.push(marker);
		}
	}
}
