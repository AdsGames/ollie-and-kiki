package game.dialogue;

import flixel.FlxState;
import game.actor.ActorManager;
import game.event.EventBus;
import game.sfx.SfxManager;

class DialogueManager {
	private static final MAX_CHARS:Int = 80;

	// Whether a sequence is active.
	public var active(default, null):Bool = false;

	private var box:DialogueBox;
	private var actorManager:ActorManager;
	private var sfxManager:SfxManager;
	private var events:EventBus;
	private var lines:Array<DialogueLine>;
	private var lineIdx:Int;

	// Hack to avoid skipping the first window of text animation.
	private var suppressAdvance:Bool;

	public function new(actorManager:ActorManager, sfxManager:SfxManager, events:EventBus) {
		this.lines = [];
		this.lineIdx = 0;
		this.suppressAdvance = false;
		this.actorManager = actorManager;
		this.sfxManager = sfxManager;
		this.events = events;
		box = new DialogueBox();
	}

	public function addToState(state:FlxState):Void {
		state.add(box);
	}

	/**
	 * Kick off a dialogue sequence. If a dialogue is already active, the lines are queued after it.
	 * @param lines
	 */
	public function startDialogue(lines:Array<DialogueLine>):Void {
		if (lines.length == 0) {
			return;
		}

		var split = [for (line in lines) for (s in splitLine(line)) s];

		// Queue so back-to-back sequences (e.g. two deliveries in one frame) all play
		if (active) {
			this.lines = this.lines.concat(split);
			return;
		}

		this.lines = split;
		lineIdx = 0;
		active = true;
		suppressAdvance = true;
		showLine(this.lines[0]);
		events.emit(DialogueStarted);
	}

	private static function splitLine(line:DialogueLine):Array<DialogueLine> {
		if (line.text.length <= MAX_CHARS) {
			return [line];
		}
		var result:Array<DialogueLine> = [];
		var current = "";
		for (word in line.text.split(" ")) {
			var candidate = current.length == 0 ? word : current + " " + word;
			if (candidate.length > MAX_CHARS && current.length > 0) {
				result.push(new DialogueLine(line.actorId, current));
				current = word;
			} else {
				current = candidate;
			}
		}

		if (current.length > 0) {
			result.push(new DialogueLine(line.actorId, current));
		}
		return result;
	}

	/**
	 * Should be called from the main update loop. Handles advancing dialogue and finishing the sequence.
	 * @param elapsed
	 */
	public function update(elapsed:Float):Void {
		if (!active) {
			return;
		}

		// The box is a state member, so Flixel already ticks its typewriter each frame.

		if (suppressAdvance) {
			suppressAdvance = false;
			return;
		}

		if (InputManager.justPressed(Interact)) {
			if (!box.advance()) {
				lineIdx++;
				if (lineIdx >= lines.length) {
					active = false;
					box.hide();
					events.emit(DialogueEnded);
				} else {
					showLine(lines[lineIdx]);
				}
			}
		}
	}

	private function showLine(line:DialogueLine):Void {
		var actor = actorManager.getActorById(line.actorId);
		box.show(line, actor, sfxManager.playVoiceChar);
	}
}
