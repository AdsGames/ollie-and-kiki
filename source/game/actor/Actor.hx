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

	public function new() {}
}
