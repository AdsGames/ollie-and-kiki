package game.actor;

import flixel.FlxSprite;
import game.location.Location;

class ActorMarker extends FlxSprite {
	public function new(actor:Actor, location:Location) {
		super(location.x, location.y);
		loadGraphic(actor.image);
		scrollFactor.set(1, 1);
	}
}
