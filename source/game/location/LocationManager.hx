package game.location;

class LocationManager {
	public var locations:Map<String, Location>;

	public function new() {
		locations = new Map();
	}

	/**
	 * Populates locations from the parsed TMX location layer (via WorldMap).
	 */
	public function loadFromWorldMap(worldLocations:Array<Location>):Void {
		for (loc in worldLocations) {
			locations.set(loc.id, loc);
		}
		trace('Loaded ${Lambda.count(locations)} locations from map.');
	}

	/**
	 * Retrieves a location by its ID.
	 * @param id The ID of the location to retrieve.
	 * @return The location with the specified ID, or null if not found.
	 */
	public function getLocationById(id:String):Null<Location> {
		var loc = locations.get(id);
		if (loc == null) {
			trace("Warning: No location found with id '" + id + "'");
		}
		return loc;
	}

	/**
	 * Get all locations.
	 */
	public function getAllLocations():Array<Location> {
		return [for (loc in locations) loc];
	}
}
