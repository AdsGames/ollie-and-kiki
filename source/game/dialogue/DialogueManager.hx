package game.dialogue;

import flixel.FlxG;
import flixel.FlxState;

class DialogueManager {
	public var active(default, null):Bool = false;

	var box:DialogueBox;
	var lines:Array<DialogueLine> = [];
	var lineIdx:Int = 0;

	public function new(state:FlxState) {
		box = new DialogueBox();
		state.add(box);
	}

	/**
	 * Kick of a dialogue sequence. If a dialogue is already active, this will be ignored.
	 * @param lines 
	 */
	public function startDialogue(lines:Array<DialogueLine>):Void {
		if (active) {
			return;
		}

		this.lines = lines;
		lineIdx = 0;
		active = true;
		box.show(lines[0]);
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

		if (FlxG.keys.justPressed.Z || FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) {
			if (!box.advance()) {
				lineIdx++;
				if (lineIdx >= lines.length) {
					active = false;
					box.hide();
				} else {
					box.show(lines[lineIdx]);
				}
			}
		}
	}
}
