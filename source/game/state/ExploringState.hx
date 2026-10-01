package game.state;

import flixel.FlxG;
import game.World;
import game.dialogue.DialogueLine;
import game.task.Task;

/**
 * Default state: free-roam gameplay. Owns interact, proximity, timer ticks,
 * and HUD toggles. Tracks the task currently being offered so it can be
 * accepted when its start dialogue ends.
 */
class ExploringState extends GameStateBase {
	private static final INTERACT_RANGE:Float = 16;

	private var pendingAcceptTask:Null<Task>;

	public function new(world:World) {
		super(world);
		pendingAcceptTask = null;

		world.events.on("DialogueEnded", function(_) acceptPendingTask());
	}

	override public function update(elapsed:Float):Void {
		#if debug
		// Cheat
		if (FlxG.keys.justPressed.ONE) {
			world.storeManager.addCoins(10);
		}
		#end

		// Toggle quest log with Q / Y button
		if (InputManager.justPressed(QuestLog)) {
			world.taskRenderer.toggle();
		}

		// Toggle minimap with M / START (requires map upgrade)
		var hasMap = world.storeManager.isPurchased("map");
		if (InputManager.justPressed(Minimap) && hasMap) {
			world.minimapRenderer.toggle();
		}
		if (hasMap) {
			world.minimapRenderer.updatePlayerPos(world.player.x, world.player.y);
		}

		// Interact key / A button
		if (InputManager.justPressed(Interact)) {
			handleInteract();
		}

		// Proximity tracking, handlers wired in World.subscribeTaskEvents()
		var proximity = world.taskManager.updateProximity(world.player.x, world.player.y);
		if (proximity.pickedUp != null) {
			world.events.emit(TaskPickedUp(proximity.pickedUp));
		}
		if (proximity.delivered != null) {
			world.events.emit(TaskDelivered(proximity.delivered));
		}

		// Tick delivery timers
		var timerResult = world.taskManager.updateTimers(elapsed);
		if (timerResult.expired != null) {
			world.events.emit(TaskExpired(timerResult.expired));
		}
		if (timerResult.warned != null) {
			world.events.emit(TaskTimerWarned(timerResult.warned));
		}

		updatePrompt();
	}

	/**
	 * Place the button bubble over whatever Interact would act on.
	 */
	private function updatePrompt():Void {
		var px = world.player.x;
		var py = world.player.y;
		var label = InputManager.label(Interact);

		var task = world.taskManager.getIdleTaskNearGiver(px, py);
		if (task != null) {
			world.interactPrompt.showAt(task.giverLocation.x + 4, task.giverLocation.y - 2, label);
			return;
		}

		var location = world.locationManager.getClosestLocation(px, py, INTERACT_RANGE);
		if (location != null) {
			world.interactPrompt.showAt(location.x + 4, location.y - 2, label);
			return;
		}

		world.interactPrompt.hide();
	}

	private function acceptPendingTask():Void {
		if (pendingAcceptTask == null) {
			return;
		}
		pendingAcceptTask.accept();
		world.events.emit(TaskAccepted(pendingAcceptTask));
		pendingAcceptTask = null;
	}

	private function handleInteract():Void {
		// A dialogue started this frame has not pushed its state yet; ignore input until it does.
		if (world.dialogueManager.active) {
			return;
		}

		var px = world.player.x;
		var py = world.player.y;
		var task = world.taskManager.getIdleTaskNearGiver(px, py);
		var closestLocation = world.locationManager.getClosestLocation(px, py, INTERACT_RANGE);

		if (task != null) {
			// Task offer, check if the player can accept
			if (world.taskManager.isCarryFull()) {
				var giverActor = world.actorManager.getActorForLocation(task.giverLocation.id);
				if (giverActor == null) {
					world.dialogueManager.startDialogue([new DialogueLine("kiki", "My paws are full!")]);
				} else {
					world.dialogueManager.startDialogue([new DialogueLine(giverActor.id, "Looks like your paws are already full!")]);
				}
			} else {
				pendingAcceptTask = task;
				world.dialogueManager.startDialogue(task.startLines);
			}
		} else if (closestLocation != null) {
			if (closestLocation.id == "store") {
				world.storeUI.open();
			} else {
				var actor = world.actorManager.getActorForLocation(closestLocation.id);
				if (actor != null) {
					world.dialogueManager.startDialogue([new DialogueLine(actor.id, actor.defaultLine)]);
				} else {
					world.dialogueManager.startDialogue([new DialogueLine("kiki", closestLocation.description)]);
				}
			}
		}
	}
}
