package game.state;

import game.World;

/**
 * Modal: a dialogue sequence is active. Only the dialogue advances; the world
 * is otherwise frozen. Popped automatically when DialogueEnded fires.
 */
class DialogueState extends GameStateBase {
	public function new(world:World) {
		super(world);
	}

	override public function update(elapsed:Float):Void {
		world.dialogueManager.update(elapsed);
	}
}
