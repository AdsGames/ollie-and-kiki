package game.location;

class LocationManager {
	private var locations:Map<String, Location>;

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

	/**
	 * Get closest location up to a threshold
	 */
	public function getClosestLocation(x:Float, y:Float, threshold:Float):Null<Location> {
		var closest:Null<Location> = null;
		var closestDist = threshold;
		for (loc in locations) {
			var dist = Math.sqrt(Math.pow(loc.x - x, 2) + Math.pow(loc.y - y, 2));
			if (dist < closestDist) {
				closestDist = dist;
				closest = loc;
			}
		}
		return closest;
	}
}
