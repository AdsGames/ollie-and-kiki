package game.item;

import flixel.graphics.FlxGraphic;

/**
 * Data type for an item that can be picked up and delivered in the game. Each item has an ID, name, description, and value.
 */
class Item {
	public var id:String;
	public var name:String;
	public var description:String;
	public var value:Int;
	public var image:FlxGraphic;

	public function new() {}
}
