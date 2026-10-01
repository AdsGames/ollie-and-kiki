package game.actor;

import flixel.graphics.FlxGraphic;

class Actor {
	public var id:String;
	public var name:String;
	public var description:String;
	public var image:FlxGraphic;
	public var imageProfile:FlxGraphic;
	public var locationId:Null<String>;
	public var voicePitch:Float;
	public var defaultLine:String;

	// Offset applied to the home-location anchor when this actor is stationary.
	public var offsetX:Float;
	public var offsetY:Float;

	// Live world coordinates. Seeded from location + offset, can be moved at runtime.
	public var x:Float;
	public var y:Float;

	public function new() {
		offsetX = 0;
		offsetY = 0;
		x = 0;
		y = 0;
	}
}
