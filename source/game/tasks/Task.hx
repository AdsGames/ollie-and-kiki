package game.tasks;

import game.Location;

class Task {
	public var name:String;
	public var description:String;
	public var completed:Bool = false;

	public var item:Item;
	public var location:Location;

	public function new(name:String, description:String) {
		this.name = name;
		this.description = description;
	}

	public function complete():Void {
		completed = true;
	}
}
