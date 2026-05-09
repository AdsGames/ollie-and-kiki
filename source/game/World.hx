package game;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxState;
import game.WorldMap;
import game.actor.ActorManager;
import game.dialogue.DialogueManager;
import game.item.ItemManager;
import game.location.LocationManager;
import game.location.LocationRenderer;
import game.task.TaskManager;

class World {
	public var map:WorldMap;
	public var player:Player;

	// Data managers
	public var actorManager:ActorManager;
	public var locationManager:LocationManager;
	public var dialogueManager:DialogueManager;
	public var itemManager:ItemManager;
	public var taskManager:TaskManager;

	// Rendering
	public var locationRenderer:LocationRenderer;

	public function new(state:FlxState) {
		map = new WorldMap(state);

		// Data
		actorManager = new ActorManager();
		actorManager.loadActors();

		itemManager = new ItemManager();
		itemManager.loadItems();

		locationManager = new LocationManager();
		locationManager.loadLocations();

		taskManager = new TaskManager();
		taskManager.load(itemManager, locationManager);

		// Location markers
		locationRenderer = new LocationRenderer();
		state.add(locationRenderer);
		locationRenderer.setLocations(locationManager.getAllLocations());

		// Dialogue system
		dialogueManager = new DialogueManager(state, actorManager);

		// Player initialization
		player = new Player(100, 100, dialogueManager);
		state.add(player);

		// Camera follow
		FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 1.0);
	}

	public function update(elapsed:Float):Void {
		FlxG.collide(player, map.midground);

		if (!dialogueManager.active) {
			// Accept the current task and show its opening dialogue
			if (FlxG.keys.justPressed.R) {
				var task = taskManager.acceptActiveTask();
				if (task != null) {
					dialogueManager.startDialogue(task.startLines);
				}
			}

			// Proximity tracking
			var completeLines = taskManager.updateProximity(player.x, player.y);
			if (completeLines != null) {
				dialogueManager.startDialogue(completeLines);
			}
		}

		dialogueManager.update(elapsed);
	}
}
