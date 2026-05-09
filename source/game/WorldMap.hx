package game;

import flixel.FlxState;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.tile.FlxTilemap;
import flixel.util.FlxDirectionFlags;
import game.Location;

class WorldMap {
	// Map
	public var tilemap:TiledMap;

	private var state:FlxState;
	private var tiles:FlxTilemap;
	private var collisionLayer:FlxTilemap;

	// Location table
	public var locations:Map<String, Location>;

	// Dimensions from map
	public var mapWidth:Int;
	public var mapHeight:Int;

	public function new(state:FlxState) {
		this.state = state;
		trace("Loading Map...");

		// Link assets
		var spritesheet:String = AssetPaths.tilemap_packed__png;
		var tmx = new TiledMap(AssetPaths.level_1__tmx);

		tiles = new FlxTilemap();
		tiles.allowCollisions = FlxDirectionFlags.NONE;

		collisionLayer = new FlxTilemap();

		mapWidth = tmx.width;
		mapHeight = tmx.height;

		state.add(tiles);
		state.add(collisionLayer);

		// Parse layers
		for (layer in tmx.layers) {
			if (layer.type == TILE) {
				var tileLayer:TiledTileLayer = cast(layer, TiledTileLayer);
				if (layer.name == "tiles") {
					tiles.loadMapFromArray(tileLayer.tileArray, tileLayer.width, tileLayer.height, spritesheet, 8, 8, OFF, 1);
					tiles.follow();
				} else {
					trace("Unknown tile layer: " + layer.name);
				}
			} else if (layer.type == OBJECT) {
				if (layer.name == "objects") {
					var objLayer:TiledObjectLayer = cast(layer, TiledObjectLayer);
					spawnObjects(objLayer);
				} else if (layer.name == "nodes") {
					var objLayer:TiledObjectLayer = cast(layer, TiledObjectLayer);
					loadNodes(objLayer);
				} else {
					trace("Unknown object layer: " + layer.name);
				}
			}
		}
	}

	/**
	 * Load nodes from tiled object layer. Nodes are used for things like quest locations.
	 * @param group - Group of nodes to load
	 */
	private function loadNodes(group:TiledObjectLayer) {
		for (obj in group.objects) {
			loadNode(obj);
		}
	}

	/**
	 * Load a node from a tiled object. Nodes are used for things like quest locations.
	 * @param obj - Tiled object to load as a node
	 */
	private function loadNode(obj:TiledObject) {
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
	private function spawnObjects(group:TiledObjectLayer) {
		for (obj in group.objects) {
			spawnObject(obj);
		}
	}

	/**
	 * Spawn an object from a tiled object. Objects are things like players, enemies, doors, etc.
	 * @param obj - Tiled object to spawn
	 */
	private function spawnObject(obj:TiledObject) {
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
