package game.actor;

import flixel.FlxSprite;
import game.location.Location;

class ActorMarker extends FlxSprite {
	public var actor:Actor;
	public var location:Location;

	public function new(actor:Actor, location:Location) {
		super(location.x, location.y);
		this.actor = actor;
		this.location = location;
		loadGraphic(actor.image);
		scrollFactor.set(1, 1);
	}
}
