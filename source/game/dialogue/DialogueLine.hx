package game.dialogue;

class DialogueLine {
	public var actorId:String;
	public var text:String;

	public function new(actorId:String, text:String) {
		this.actorId = actorId;
		this.text = text;
	}
}
