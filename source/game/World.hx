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
import game.task.Task;
import game.task.TaskManager;
import game.task.TaskRenderer;

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
	public var taskRenderer:TaskRenderer;

	// Task to accept once the start dialogue finishes
	var pendingAcceptTask:Null<Task> = null;

	public function new(state:FlxState) {
		map = new WorldMap(state);

		// Data
		actorManager = new ActorManager();
		actorManager.loadActors();

		itemManager = new ItemManager();
		itemManager.loadItems();

		locationManager = new LocationManager();
		locationManager.loadFromWorldMap(map.locations);

		taskManager = new TaskManager();
		taskManager.load(itemManager, locationManager);

		// Location markers
		locationRenderer = new LocationRenderer();
		state.add(locationRenderer);
		locationRenderer.setLocations(locationManager.getAllLocations());

		// Dialogue system
		dialogueManager = new DialogueManager(state, actorManager);

		// Quest log HUD
		taskRenderer = new TaskRenderer();
		state.add(taskRenderer);

		// Player initialization
		var kikisHouse = locationManager.getLocationById("kikis_house");
		player = new Player(kikisHouse.x, kikisHouse.y, dialogueManager);
		state.add(player);

		// Camera follow
		FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 1.0);
	}

	public function update(elapsed:Float):Void {
		FlxG.collide(player, map.midground);

		if (!dialogueManager.active) {
			// Accept the pending task now that its start dialogue has finished
			if (pendingAcceptTask != null) {
				pendingAcceptTask.accept();
				pendingAcceptTask = null;
			}

			// Interact key near a giver NPC → show start dialogue, then accept
			if (FlxG.keys.justPressed.Z || FlxG.keys.justPressed.E || FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) {
				var task = taskManager.getIdleTaskNearGiver(player.x, player.y);
				if (task != null) {
					pendingAcceptTask = task;
					dialogueManager.startDialogue(task.startLines);
				}
			}

			// Proximity tracking
			var completeLines = taskManager.updateProximity(player.x, player.y);
			if (completeLines != null) {
				dialogueManager.startDialogue(completeLines);
			}
		}

		// Update renderers
		locationRenderer.updateFromTasks(taskManager.tasks);
		taskRenderer.updateTasks(taskManager.tasks);

		dialogueManager.update(elapsed);
	}
}
