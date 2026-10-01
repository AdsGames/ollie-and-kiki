package game.state;

/**
 * Pushdown automaton of game states. Only the top state ticks each frame.
 * Push/pop are driven by events (e.g. DialogueStarted pushes a DialogueState).
 */
class GameStateStack {
	private var states:Array<GameStateBase>;

	public function new() {
		states = [];
	}

	public function push(state:GameStateBase):Void {
		states.push(state);
		state.enter();
	}

	public function pop():Null<GameStateBase> {
		if (states.length == 0) {
			return null;
		}
		var top = states.pop();
		top.exit();
		return top;
	}

	/**
	 * Pop states from the top until one of the given class is removed.
	 * No-op if no matching state is on the stack. Used when an event implies
	 * a specific state should end, regardless of what was pushed on top of it.
	 */
	public function popOfType<T:GameStateBase>(cls:Class<T>):Void {
		var target = Type.getClassName(cls);
		for (i in 0...states.length) {
			var idx = states.length - 1 - i;
			if (Type.getClassName(Type.getClass(states[idx])) == target) {
				states[idx].exit();
				states.splice(idx, 1);
				return;
			}
		}
	}

	public function current():Null<GameStateBase> {
		if (states.length == 0) {
			return null;
		}
		return states[states.length - 1];
	}

	public function update(elapsed:Float):Void {
		var top = current();
		if (top != null) {
			top.update(elapsed);
		}
	}
}
