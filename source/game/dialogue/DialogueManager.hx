package game.dialogue;

import flixel.FlxState;
import game.actor.ActorManager;
import game.sfx.SfxManager;

class DialogueManager {
	private static final MAX_CHARS:Int = 80;

	// Whether a sequence is active.
	public var active(default, null):Bool = false;

	private var box:DialogueBox;
	private var actorManager:ActorManager;
	private var sfxManager:SfxManager;
	private var lines:Array<DialogueLine>;
	private var lineIdx:Int;

	// Hack to avoid skipping the first window of text animation.
	private var suppressAdvance:Bool;

	public function new(actorManager:ActorManager, sfxManager:SfxManager) {
		this.lines = [];
		this.lineIdx = 0;
		this.suppressAdvance = false;
		this.actorManager = actorManager;
		this.sfxManager = sfxManager;
		box = new DialogueBox();
	}

	public function addToState(state:FlxState):Void {
		state.add(box);
	}

	/**
	 * Kick off a dialogue sequence. If a dialogue is already active, this will be ignored.
	 * @param lines
	 */
	public function startDialogue(lines:Array<DialogueLine>):Void {
		if (active || lines.length == 0) {
			return;
		}

		this.lines = [for (line in lines) for (split in splitLine(line)) split];
		lineIdx = 0;
		active = true;
		suppressAdvance = true;
		showLine(this.lines[0]);
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

		box.update(elapsed);

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
