package game;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxState;
import game.WorldMap;
import game.actor.ActorManager;
import game.actor.ActorRenderer;
import game.ambience.AmbienceManager;
import game.dialogue.DialogueLine;
import game.dialogue.DialogueManager;
import game.economy.CurrencyRenderer;
import game.item.InventoryRenderer;
import game.item.ItemManager;
import game.location.LocationManager;
import game.location.LocationRenderer;
import game.sfx.SfxManager;
import game.task.Task;
import game.task.TaskManager;
import game.task.TaskRenderer;

class World {
	public var map:WorldMap;
	public var player:Player;

	// Data managers
	public var sfxManager:SfxManager;
	public var ambienceManager:AmbienceManager;
	public var actorManager:ActorManager;
	public var locationManager:LocationManager;
	public var dialogueManager:DialogueManager;
	public var itemManager:ItemManager;
	public var taskManager:TaskManager;

	// Rendering
	public var actorRenderer:ActorRenderer;
	public var locationRenderer:LocationRenderer;
	public var taskRenderer:TaskRenderer;
	public var inventoryRenderer:InventoryRenderer;
	public var currencyRenderer:CurrencyRenderer;

	public var coins:Int = 0;

	// Task to accept once the start dialogue finishes
	var pendingAcceptTask:Null<Task> = null;

	public function new(state:FlxState) {
		map = new WorldMap(state);

		// Data
		sfxManager = new SfxManager();

		ambienceManager = new AmbienceManager();
		ambienceManager.loadAmbiences();

		actorManager = new ActorManager();
		actorManager.loadActors();

		itemManager = new ItemManager();
		itemManager.loadItems();

		locationManager = new LocationManager();
		locationManager.loadFromWorldMap(map.locations);

		taskManager = new TaskManager();
		taskManager.load(itemManager, locationManager);

		// Actor sprites at their home locations
		actorRenderer = new ActorRenderer();
		state.add(actorRenderer);
		actorRenderer.setActors(actorManager, locationManager);

		// Location markers
		locationRenderer = new LocationRenderer();
		state.add(locationRenderer);
		locationRenderer.setLocations(locationManager.getAllLocations());

		// Dialogue system
		dialogueManager = new DialogueManager(actorManager, sfxManager);

		// Player initialization
		var kikisHouse = locationManager.getLocationById("kikis_house");
		player = new Player(kikisHouse.x, kikisHouse.y, dialogueManager);
		state.add(player);

		// Camera follow
		FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 1.0);

		// Foreground layers render on top of the player
		map.addForeground(state);

		// HUD renders on top of world geometry
		taskRenderer = new TaskRenderer();
		state.add(taskRenderer);

		inventoryRenderer = new InventoryRenderer();
		state.add(inventoryRenderer);

		currencyRenderer = new CurrencyRenderer();
		state.add(currencyRenderer);

		// Dialogue box renders on top of everything
		dialogueManager.addToState(state);
	}

	public function update(elapsed:Float):Void {
		FlxG.collide(player, map.collision);

		if (!dialogueManager.active) {
			// Accept the pending task now that its start dialogue has finished
			if (pendingAcceptTask != null) {
				pendingAcceptTask.accept();
				pendingAcceptTask = null;
			}

			// Interact key near a giver NPC → show start dialogue, then accept
			if (FlxG.keys.justPressed.Z || FlxG.keys.justPressed.E || FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) {
				var task = taskManager.getIdleTaskNearGiver(player.x, player.y);
				var closestLocation = locationManager.getClosestLocation(player.x, player.y, 16);

				if (task != null) {
					pendingAcceptTask = task;
					dialogueManager.startDialogue(task.startLines);
				} else if (closestLocation != null) {
					// Check for actor at location first.
					var actor = actorManager.getActorForLocation(closestLocation.id);
					if (actor != null) {
						var line = new DialogueLine(actor.id, actor.defaultLine);
						dialogueManager.startDialogue(([line]));
						return;
					} else {
						var line = new DialogueLine("kiki", closestLocation.description);
						dialogueManager.startDialogue(([line]));
					}
				}
			}

			// Proximity tracking. Fires pickup and delivery events
			var proximity = taskManager.updateProximity(player.x, player.y);
			if (proximity.pickedUp != null) {
				sfxManager.playTaskPickup();
			}
			if (proximity.delivered != null) {
				coins += proximity.delivered.item.value;
				sfxManager.playTaskDelivered();
				dialogueManager.startDialogue(proximity.delivered.completeLines);
			}

			// Tick delivery timers; expired tasks revert silently to Accepted
			var timerResult = taskManager.updateTimers(elapsed);
			if (timerResult.expired != null) {
				sfxManager.playTaskExpired();
			}
			if (timerResult.warned != null) {
				sfxManager.playTimerWarning();
			}
		}

		// Update renderers
		actorRenderer.updateFromTasks(taskManager.tasks);
		locationRenderer.updateFromTasks(taskManager.tasks);
		taskRenderer.updateTasks(taskManager.tasks);
		inventoryRenderer.updateFromTasks(taskManager.tasks);
		currencyRenderer.updateCoins(coins);

		dialogueManager.update(elapsed);
		ambienceManager.update(player.x, player.y, map.ambienceZones);
	}
}
