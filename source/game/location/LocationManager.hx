package game.location;

import openfl.Assets;

class LocationManager {
	public var locations:Array<Location>;

	public function new() {
		locations = [];
	}

	/**
	 * Loads locations from a JSON file and populates the locations array.
	 */
	public function loadLocations():Void {
		var raw = Assets.getText(AssetPaths.locations__json);
		var data:Array<{
			var id:String;
			var name:String;
			var x:Float;
			var y:Float;
		}> = haxe.Json.parse(raw);

		for (entry in data) {
			var location = new Location();
			location.id = entry.id;
			location.name = entry.name;
			location.x = entry.x;
			location.y = entry.y;
			locations.push(location);

			trace('Loaded location: ' + location.name);
		}
	}

	/**
	 * Retrieves an item by its ID.
	 * @param id The ID of the item to retrieve.
	 * @return The location with the specified ID, or null if not found.
	 */
	public function getLocationById(id:String):Null<Location> {
		for (loc in locations) {
			if (loc.id == id) {
				return loc;
			}
		}
		return null;
	}

	/**
	 * Get all locations.
	 */
	public function getAllLocations():Array<Location> {
		return locations;
	}
}
