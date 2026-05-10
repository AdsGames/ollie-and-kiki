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
import game.minimap.MinimapRenderer;
import game.sfx.SfxManager;
import game.store.StoreManager;
import game.store.StoreUI;
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
	public var storeManager:StoreManager;

	// Rendering
	public var actorRenderer:ActorRenderer;
	public var locationRenderer:LocationRenderer;
	public var taskRenderer:TaskRenderer;
	public var inventoryRenderer:InventoryRenderer;
	public var currencyRenderer:CurrencyRenderer;
	public var minimapRenderer:MinimapRenderer;
	public var storeUI:StoreUI;

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

		storeManager = new StoreManager();

		taskManager = new TaskManager(storeManager);
		taskManager.load(itemManager, locationManager);

		// Actor sprites at their home locations
		actorRenderer = new ActorRenderer(actorManager, locationManager, taskManager);
		state.add(actorRenderer);

		// Dialogue system must be ready before player
		dialogueManager = new DialogueManager(actorManager, sfxManager);

		// Player initialization
		var kikisHouse = locationManager.getLocationById("kikis_house");
		player = new Player(kikisHouse.x, kikisHouse.y, dialogueManager, storeManager);
		state.add(player);

		// Camera follow
		FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 1.0);

		// Foreground layers render on top of the player
		map.addForeground(state);

		// Location markers
		locationRenderer = new LocationRenderer(locationManager, taskManager);
		state.add(locationRenderer);

		// HUD renders on top of world geometry
		taskRenderer = new TaskRenderer(taskManager);
		state.add(taskRenderer);

		inventoryRenderer = new InventoryRenderer(taskManager);
		state.add(inventoryRenderer);

		currencyRenderer = new CurrencyRenderer(storeManager);
		state.add(currencyRenderer);

		// Dialogue box renders on top of everything
		dialogueManager.addToState(state);

		// Minimap and store UI sit above dialogue
		minimapRenderer = new MinimapRenderer(map.mapWidth, map.mapHeight, locationManager);
		state.add(minimapRenderer);

		storeUI = new StoreUI(storeManager);
		state.add(storeUI);
	}

	public function update(elapsed:Float):Void {
		FlxG.collide(player, map.collision);

		if (storeManager.isOpen) {
			return;
		}

		// Cheat
		if (FlxG.keys.justPressed.ONE) {
			storeManager.addCoins(10);
		}

		// Toggle minimap with M (requires map upgrade)
		if (FlxG.keys.justPressed.M && storeManager.isPurchased("map")) {
			minimapRenderer.toggle();
		}
		if (storeManager.isPurchased("map")) {
			minimapRenderer.updatePlayerPos(player.x, player.y);
		}

		if (!dialogueManager.active) {
			// Accept the pending task now that its start dialogue has finished
			if (pendingAcceptTask != null) {
				pendingAcceptTask.accept();
				pendingAcceptTask = null;
			}

			// Interact key
			if (FlxG.keys.justPressed.Z || FlxG.keys.justPressed.E || FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) {
				var task = taskManager.getIdleTaskNearGiver(player.x, player.y);
				var closestLocation = locationManager.getClosestLocation(player.x, player.y, 16);

				if (task != null) {
					// Task offer, check if the player can accept
					if (taskManager.isCarryFull()) {
						// Already maxxed out quests
						var giverActor = actorManager.getActorForLocation(task.giverLocation.id);
						if (giverActor == null) {
							dialogueManager.startDialogue(([new DialogueLine("kiki", "My paws are full!")] : Array<DialogueLine>));
						} else {
							dialogueManager.startDialogue(([new DialogueLine(giverActor.id, "Looks like your paws are already full!")] : Array<DialogueLine>));
						}
					} else {
						// Offer the task
						pendingAcceptTask = task;
						dialogueManager.startDialogue(task.startLines);
					}
				} else if (closestLocation != null) {
					// Near a location
					if (closestLocation.id == "store") {
						// Open the store UI
						storeUI.open();
					} else {
						// Just show the location description
						var actor = actorManager.getActorForLocation(closestLocation.id);
						if (actor != null) {
							dialogueManager.startDialogue(([new DialogueLine(actor.id, actor.defaultLine)] : Array<DialogueLine>));
						} else {
							dialogueManager.startDialogue(([new DialogueLine("kiki", closestLocation.description)] : Array<DialogueLine>));
						}
					}
				}
			}

			// Proximity tracking
			var proximity = taskManager.updateProximity(player.x, player.y);
			if (proximity.pickedUp != null) {
				sfxManager.playTaskPickup();
			}
			if (proximity.delivered != null) {
				storeManager.addCoins(proximity.delivered.item.value);
				sfxManager.playTaskDelivered();
				dialogueManager.startDialogue(proximity.delivered.completeLines);
			}

			// Tick delivery timers
			var timerResult = taskManager.updateTimers(elapsed);
			if (timerResult.expired != null) {
				sfxManager.playTaskExpired();
			}
			if (timerResult.warned != null) {
				sfxManager.playTimerWarning();
			}
		}

		dialogueManager.update(elapsed);
		ambienceManager.update(player.x, player.y, map.ambienceZones);
	}
}
