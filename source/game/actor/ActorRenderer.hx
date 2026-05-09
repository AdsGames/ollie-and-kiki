package game.actor;

import flixel.group.FlxGroup;
import game.location.LocationManager;

class ActorRenderer extends FlxGroup {
	public function new() {
		super();
	}

	public function setActors(actorManager:ActorManager, locationManager:LocationManager):Void {
		clear();
		for (actor in actorManager.actors) {
			if (actor.locationId == null) {
				continue;
			}
			var location = locationManager.getLocationById(actor.locationId);
			if (location == null) {
				continue;
			}
			add(new ActorMarker(actor, location));
		}
	}
}
