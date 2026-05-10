package game.ambience;

class AmbiencePlayer {
	public var ambience:Ambience;
	public var time:Float = 0;

	public function new(ambience:Ambience) {
		this.ambience = ambience;
	}

	public function update(elapsed:Float):Void {
		time += elapsed;
	}
}
