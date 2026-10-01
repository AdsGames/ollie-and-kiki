package game;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxState;
import game.actor.ActorManager;
import game.actor.ActorRenderer;
import game.ambience.AmbienceManager;
import game.dialogue.DialogueLine;
import game.dialogue.DialogueManager;
import game.event.EventBus;
import game.item.InventoryRenderer;
import game.item.ItemManager;
import game.location.LocationManager;
import game.location.LocationRenderer;
import game.minimap.MinimapRenderer;
import game.sfx.SfxManager;
import game.state.DialogueState;
import game.state.ExploringState;
import game.state.GameStateStack;
import game.state.StoreState;
import game.store.CurrencyRenderer;
import game.store.StoreManager;
import game.store.StoreUI;
import game.task.QuestArrowRenderer;
import game.task.TaskManager;
import game.task.TaskRenderer;

class World {
	public var map:WorldMap;
	public var player:Player;

	// Event bus
	public var events:EventBus;

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
	public var questArrowRenderer:QuestArrowRenderer;
	public var minimapRenderer:MinimapRenderer;
	public var storeUI:StoreUI;

	// State stack
	private var stack:GameStateStack;

	public function new(state:FlxState) {
		map = new WorldMap(state);

		events = new EventBus();

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

		dialogueManager = new DialogueManager(actorManager, sfxManager, events);

		storeManager = new StoreManager(dialogueManager, events);

		taskManager = new TaskManager(storeManager);
		taskManager.load(itemManager, locationManager);

		subscribeTaskEvents();

		// Actor sprites at their home locations
		actorRenderer = new ActorRenderer(actorManager, locationManager, taskManager);
		state.add(actorRenderer);

		// Player initialization
		var kikisHouse = locationManager.getLocationById("kikis_house");
		player = new Player(kikisHouse.x, kikisHouse.y, storeManager);
		state.add(player);

		// Camera follow
		FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 1.0);

		// Foreground layers render on top of the player
		map.addForeground(state);

		// Quest exclamation marks render above foreground
		state.add(actorRenderer.questLabels);

		// HUD renders on top of world geometry
		locationRenderer = new LocationRenderer(locationManager, taskManager);
		state.add(locationRenderer);

		questArrowRenderer = new QuestArrowRenderer(taskManager);
		state.add(questArrowRenderer);

		currencyRenderer = new CurrencyRenderer(storeManager, events);
		state.add(currencyRenderer);

		// Popup UIs
		taskRenderer = new TaskRenderer(taskManager);
		state.add(taskRenderer);

		minimapRenderer = new MinimapRenderer(map.mapWidth, map.mapHeight, locationManager);
		state.add(minimapRenderer);

		storeUI = new StoreUI(storeManager);
		state.add(storeUI);

		inventoryRenderer = new InventoryRenderer(taskManager);
		state.add(inventoryRenderer);

		// Dialogue box renders on top of everything
		dialogueManager.addToState(state);

		// Set up state stack with Exploring as the base, then wire transitions.
		stack = new GameStateStack();
		stack.push(new ExploringState(this));
		subscribeStateTransitions();

		// Intro dialogue. Flush so the resulting DialogueStarted event applies
		// before the first update tick.
		dialogueManager.startDialogue([new DialogueLine("kiki", "I should go see Ollie... I think he needs me.")]);
		events.flush();
	}

	public function update(elapsed:Float):Void {
		FlxG.collide(player, map.collision);
		stack.update(elapsed);
		events.flush();
		ambienceManager.update(player.x, player.y, map.ambienceZones);
	}

	private function subscribeTaskEvents():Void {
		events.on("TaskPickedUp", function(_) sfxManager.playTaskPickup());
		events.on("TaskExpired", function(_) sfxManager.playTaskExpired());
		events.on("TaskTimerWarned", function(_) sfxManager.playTimerWarning());
		events.on("TaskDelivered", function(event) switch (event) {
			case TaskDelivered(task):
				storeManager.addCoins(task.item.value);
				sfxManager.playTaskDelivered();
				dialogueManager.startDialogue(task.completeLines);
			default:
		});
	}

	private function subscribeStateTransitions():Void {
		events.on("DialogueStarted", function(_) {
			stack.push(new DialogueState(this));
			refreshFrozen();
		});
		events.on("DialogueEnded", function(_) {
			stack.popOfType(DialogueState);
			refreshFrozen();
		});
		events.on("StoreOpened", function(_) {
			stack.push(new StoreState(this));
			refreshFrozen();
		});
		events.on("StoreClosed", function(_) {
			stack.popOfType(StoreState);
			refreshFrozen();
		});
	}

	private function refreshFrozen():Void {
		// Player can only move during the base Exploring state.
		player.frozen = !Std.isOfType(stack.current(), ExploringState);
	}
}
