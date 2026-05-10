package game;

import flixel.FlxState;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.tile.FlxTilemap;
import flixel.util.FlxDirectionFlags;
import game.ambience.AmbienceZone;
import game.location.Location;

class WorldMap {
	// Map
	public var tilemap:TiledMap;

	// Terrain is the bottom layer
	public var terrain:FlxTilemap;

	// Midground is the middle layer, used for things like bushes, low walls, etc.
	public var midground:FlxTilemap;

	// Foreground is the top layer, used for things like tree canopies, high walls, etc.
	public var foreground:FlxTilemap;

	// Collision layer, used for pathfinding and collision detection. Not rendered.
	public var collision:FlxTilemap;

	// Location table
	public var locations:Array<Location>;

	// Ambience zones parsed from the map
	public var ambienceZones:Array<AmbienceZone>;

	// Map width in pixels (not tiles)
	public var mapWidth:Int;

	// Map height in pixels (not tiles)
	public var mapHeight:Int;

	public function new(state:FlxState) {
		trace("Loading Map...");

		locations = [];
		ambienceZones = [];

		// Link assets
		var spritesheet:String = AssetPaths.tilemap_packed__png;
		var tmx = new TiledMap(AssetPaths.level_1__tmx);

		terrain = new FlxTilemap();
		terrain.allowCollisions = FlxDirectionFlags.NONE;

		midground = new FlxTilemap();
		midground.allowCollisions = FlxDirectionFlags.NONE;

		foreground = new FlxTilemap();
		foreground.allowCollisions = FlxDirectionFlags.NONE;

		collision = new FlxTilemap();
		collision.visible = false;

		mapWidth = tmx.width;
		mapHeight = tmx.height;

		state.add(terrain);
		state.add(midground);

		// Parse layers
		for (layer in tmx.layers) {
			parseTiledLayer(layer, spritesheet);
		}
	}

	private function parseTiledLayer(layer:TiledLayer, spritesheet:String):Void {
		if (layer.type == TILE) {
			var tileLayer:TiledTileLayer = cast(layer, TiledTileLayer);
			if (layer.name == "terrain") {
				terrain.loadMapFromArray(tileLayer.tileArray, tileLayer.width, tileLayer.height, spritesheet, 8, 8, OFF, 1);
				terrain.follow();
			} else if (layer.name == "midlayer") {
				midground.loadMapFromArray(tileLayer.tileArray, tileLayer.width, tileLayer.height, spritesheet, 8, 8, OFF, 1);
				midground.follow();
			} else if (layer.name == "foreground") {
				foreground.loadMapFromArray(tileLayer.tileArray, tileLayer.width, tileLayer.height, spritesheet, 8, 8, OFF, 1);
				foreground.follow();
			} else if (layer.name == "collision") {
				collision.loadMapFromArray(tileLayer.tileArray, tileLayer.width, tileLayer.height, spritesheet, 8, 8, OFF, 1);
				collision.follow();
			} else {
				trace("Unknown tile layer: " + layer.name);
			}
		} else if (layer.type == OBJECT) {
			var objLayer:TiledObjectLayer = cast(layer, TiledObjectLayer);
			if (layer.name == "objects") {
				spawnObjects(objLayer);
			} else if (layer.name == "nodes") {
				loadNodes(objLayer);
			} else if (layer.name == "locations") {
				loadLocationLayer(objLayer);
			} else if (layer.name == "ambience") {
				loadAmbienceLayer(objLayer);
			} else {
				trace("Unknown object layer: " + layer.name);
			}
		}
	}

	private function loadAmbienceLayer(group:TiledObjectLayer):Void {
		for (obj in group.objects) {
			ambienceZones.push({id: obj.name, x: obj.x, y: obj.y});
			trace('Loaded ambience zone: ${obj.name} at ${obj.x}, ${obj.y}');
		}
	}

	private function loadLocationLayer(group:TiledObjectLayer):Void {
		for (obj in group.objects) {
			var id = obj.properties.get("id");
			if (id == null || id.length == 0) {
				trace('Location "${obj.name}" has no id property, skipping.');
				continue;
			}
			var loc = new Location();
			loc.id = id;
			loc.name = obj.name;
			loc.description = obj.properties.get("description");
			loc.x = obj.x;
			loc.y = obj.y;
			locations.push(loc);
			trace('Loaded location: ${loc.name} (${loc.id}) at ${loc.x}, ${loc.y}');
		}
	}

	/**
	 * Load nodes from tiled object layer. Nodes are used for things like quest locations.
	 * @param group - Group of nodes to load
	 */
	private function loadNodes(group:TiledObjectLayer):Void {
		for (obj in group.objects) {
			loadNode(obj);
		}
	}

	/**
	 * Load a node from a tiled object. Nodes are used for things like quest locations.
	 * @param obj - Tiled object to load as a node
	 */
	private function loadNode(obj:TiledObject):Void {
		switch (obj.name) {
			case "location":
				var locationName = obj.properties.get("enemy_name");
				if (locationName.length == 0) {
					trace("Patrol point " + obj.gid + " has no enemy_name");
					return;
				}

			default:
				trace("Could not load node " + obj.gid);
				return;
		}
	}

	/**
	 * Spawn objects from tiled object layer. Objects are things like players, enemies, doors, etc.
	 * @param group - Group of objects to spawn
	 */
	private function spawnObjects(group:TiledObjectLayer):Void {
		for (obj in group.objects) {
			spawnObject(obj);
		}
	}

	public function addForeground(state:FlxState):Void {
		state.add(foreground);
		state.add(collision);
	}

	/**
	 * Spawn an object from a tiled object. Objects are things like players, enemies, doors, etc.
	 * @param obj - Tiled object to spawn
	 */
	private function spawnObject(obj:TiledObject):Void {
		switch (obj.type) {
			case "player":
				trace("Spawning player at " + obj.x + ", " + obj.y);
				return;
			default:
				trace("Unknown map object type: " + obj.type + " id:" + obj.gid);
				return;
		}
	}
}
