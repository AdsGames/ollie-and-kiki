package game.event;

/**
 * Queued pub/sub. Handlers subscribe by enum constructor name; emitted events
 * are buffered and dispatched in order when `flush()` is called (typically once
 * per frame). Queueing avoids reentrancy when a handler emits another event.
 */
class EventBus {
	private var listeners:Map<String, Array<GameEvent->Void>>;
	private var queue:Array<GameEvent>;

	public function new() {
		listeners = new Map();
		queue = [];
	}

	public function on(eventName:String, handler:GameEvent->Void):Void {
		var arr = listeners.get(eventName);

		if (arr == null) {
			arr = [];
			listeners.set(eventName, arr);
		}

		arr.push(handler);
	}

	public function emit(event:GameEvent):Void {
		queue.push(event);
	}

	public function flush():Void {
		// Swap so handlers that emit are dispatched on the next flush.
		var current = queue;
		queue = [];
		for (event in current) {
			var name = Type.enumConstructor(event);
			var arr = listeners.get(name);

			if (arr == null) {
				continue;
			}

			for (handler in arr) {
				handler(event);
			}
		}
	}
}
