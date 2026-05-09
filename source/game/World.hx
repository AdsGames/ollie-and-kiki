package game;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxState;
import game.WorldMap;
import game.dialogue.DialogueLine;
import game.dialogue.DialogueManager;
import game.item.ItemManager;
import game.location.LocationManager;
import game.location.LocationRenderer;
import game.task.TaskManager;

class World {
	public var map:WorldMap;
	public var player:Player;

	// Data managers
	public var locationManager:LocationManager;
	public var dialogueManager:DialogueManager;
	public var itemManager:ItemManager;
	public var taskManager:TaskManager;

	// Rendering
	public var locationRenderer:LocationRenderer;

	public function new(state:FlxState) {
		map = new WorldMap(state);

		// Dialogue system
		dialogueManager = new DialogueManager(state);

		// Item manager
		itemManager = new ItemManager();
		itemManager.loadItems();

		// Location
		locationManager = new LocationManager();
		locationManager.loadLocations();

		locationRenderer = new LocationRenderer();
		state.add(locationRenderer);

		// Update location markers
		locationRenderer.setLocations(locationManager.getAllLocations());

		// Task manager
		taskManager = new TaskManager();
		taskManager.load(itemManager, locationManager);

		// Player initialization
		player = new Player(100, 100, dialogueManager);
		state.add(player);

		// Camera follow
		FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 1.0);
	}

	public function update(elapsed:Float):Void {
		FlxG.collide(player, map.midground);
		dialogueManager.update(elapsed);
	}
}
