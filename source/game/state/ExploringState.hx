package game.state;

import flixel.FlxG;
import game.World;
import game.actor.Actor;
import game.dialogue.DialogueLine;
import game.location.Location;
import game.task.Task;

/**
 * What the Interact button would act on at the player's position.
 */
enum InteractTarget {
	QuestGiver(task:Task, actor:Null<Actor>);
	Chat(actor:Actor);
	Place(location:Location);
}

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
		world.timeController.update(elapsed);
		if (world.timeController.checkDayEnded()) {
			world.events.emit(DayEnded(world.timeController.getDay() - 1));
			return;
		}

		#if debug
		// Cheat
		if (FlxG.keys.justPressed.ONE) {
			world.storeManager.addCoins(10);
		}
		#end

		if (InputManager.justPressed(Pause)) {
			world.interactPrompt.hide();
			world.pauseMenu.open();
			return;
		}

		// Toggle quest log with Q / Y button
		if (InputManager.justPressed(QuestLog)) {
			world.taskRenderer.toggle();
		}

		// Toggle minimap with M / SELECT (requires map upgrade)
		var hasMap = world.storeManager.hasUnlock("minimap");
		if (InputManager.justPressed(Minimap) && hasMap) {
			world.minimapRenderer.toggle();
		}
		if (hasMap) {
			world.minimapRenderer.updatePlayerPos(world.player.x, world.player.y);
		}

		// Interact key / A button
		var target = findInteractTarget();
		if (InputManager.justPressed(Interact) && target != null) {
			handleInteract(target);
		}

		// Photo snap for Photo-type tasks
		if (InputManager.justPressed(Photo)) {
			world.taskManager.tryPhotoSnap(world.player.x, world.player.y);
		}

		// Proximity tracking + delivery timers, handlers wired in World.subscribeTaskEvents()
		world.taskManager.updateProximity(world.player.x, world.player.y);
		world.taskManager.updateTimers(elapsed);

		updatePrompt(target);
	}

	private function acceptPendingTask():Void {
		if (pendingAcceptTask == null) {
			return;
		}
		pendingAcceptTask.accept();
		world.events.emit(TaskAccepted(pendingAcceptTask));
		pendingAcceptTask = null;
	}

	private function findInteractTarget():Null<InteractTarget> {
		var px = world.player.x;
		var py = world.player.y;

		var task = world.taskManager.getIdleTaskNearGiver(px, py);
		if (task != null) {
			return QuestGiver(task, world.actorManager.getActorForLocation(task.giverLocation.id));
		}

		var closestLocation = world.locationManager.getClosestLocation(px, py, INTERACT_RANGE);
		var closestActor = world.actorManager.getClosestActor(px, py, INTERACT_RANGE);

		// Pick whichever is closer to the player: an actor (chat) or a location.
		// Actors absent due to escort are skipped so the player falls through to the
		// location's description.
		if (closestActor != null
			&& closestActor.locationId != null
			&& world.taskManager.isLocationActorEscorting(closestActor.locationId)) {
			closestActor = null;
		}

		var actorWins = closestActor != null
			&& (closestLocation == null || isCloser(px, py, closestActor.x, closestActor.y, closestLocation.x, closestLocation.y));
		if (actorWins) {
			return Chat(closestActor);
		}
		if (closestLocation != null) {
			return Place(closestLocation);
		}
		return null;
	}

	private function handleInteract(target:InteractTarget):Void {
		// A dialogue started this frame has not pushed its state yet; ignore input until it does.
		if (world.dialogueManager.active) {
			return;
		}

		switch (target) {
			case QuestGiver(task, giverActor):
				if (task.consumesCarry() && world.taskManager.isCarryFull()) {
					if (giverActor == null) {
						world.dialogueManager.startDialogue([new DialogueLine("kiki", "My paws are full!")]);
					} else {
						world.dialogueManager.startDialogue([new DialogueLine(giverActor.id, "Looks like your paws are already full!")]);
					}
				} else {
					pendingAcceptTask = task;
					world.dialogueManager.startDialogue(task.startLines);
				}
			case Chat(actor):
				world.dialogueManager.startDialogue([new DialogueLine(actor.id, actor.defaultLine)]);
			case Place(location):
				if (location.id == "store") {
					world.storeUI.open();
				} else {
					world.dialogueManager.startDialogue([new DialogueLine("kiki", location.description)]);
				}
		}
	}

	/**
	 * Place the button bubble over the interact target. A photo opportunity
	 * takes priority since it is time-limited.
	 */
	private function updatePrompt(target:Null<InteractTarget>):Void {
		var prompt = world.interactPrompt;

		var photoTask = world.taskManager.findPhotoTask(world.player.x, world.player.y);
		if (photoTask != null) {
			var loc = world.taskManager.photoTargetLocation(photoTask);
			var actor = world.actorManager.getActorForLocation(loc.id);
			if (actor != null) {
				prompt.showAt(actor.x + actor.image.width, actor.y + 1, InputManager.label(Photo));
			} else {
				prompt.showAt(loc.x + 4, loc.y - 2, InputManager.label(Photo));
			}
			return;
		}

		if (target == null) {
			prompt.hide();
			return;
		}

		var label = InputManager.label(Interact);
		switch (target) {
			case QuestGiver(task, actor):
				if (actor != null) {
					prompt.showAt(actor.x + actor.image.width, actor.y + 1, label);
				} else {
					prompt.showAt(task.giverLocation.x + 4, task.giverLocation.y - 2, label);
				}
			case Chat(actor):
				prompt.showAt(actor.x + actor.image.width, actor.y + 1, label);
			case Place(location):
				prompt.showAt(location.x + 4, location.y - 2, label);
		}
	}

	private inline function isCloser(px:Float, py:Float, ax:Float, ay:Float, bx:Float, by:Float):Bool {
		var da = (ax - px) * (ax - px) + (ay - py) * (ay - py);
		var db = (bx - px) * (bx - px) + (by - py) * (by - py);
		return da <= db;
	}
}
