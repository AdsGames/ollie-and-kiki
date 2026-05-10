package game.actor;

import flixel.graphics.FlxGraphic;
import openfl.Assets;

class ActorManager {
	// Map of all loaded actors keyed by actor ID.
	public var actors:Map<String, Actor>;

	public function new() {
		actors = new Map();
	}

	/**
	 * Loads actors from JSON. Actors whose image or imageProfile asset is missing are skipped.
	 */
	public function loadActors():Void {
		var raw = Assets.getText(AssetPaths.actors__json);
		var data:Array<{
			id:String,
			name:String,
			description:String,
			image:String,
			image_profile:String,
			voice_pitch:Float,
			default_line:String,
			?location_id:String
		}> = haxe.Json.parse(raw);

		for (entry in data) {
			if (!Assets.exists(entry.image)) {
				trace('Skipping actor "${entry.id}": missing image "${entry.image}".');
				continue;
			}
			if (!Assets.exists(entry.image_profile)) {
				trace('Skipping actor "${entry.id}": missing image_profile "${entry.image_profile}".');
				continue;
			}

			var actor = new Actor();
			actor.id = entry.id;
			actor.name = entry.name;
			actor.description = entry.description;
			var img = FlxGraphic.fromBitmapData(Assets.getBitmapData(entry.image), false);
			img.persist = true;
			actor.image = img;

			var imgProfile = FlxGraphic.fromBitmapData(Assets.getBitmapData(entry.image_profile), false);
			imgProfile.persist = true;
			actor.imageProfile = imgProfile;
			actor.locationId = entry.location_id;
			actor.voicePitch = entry.voice_pitch;
			actor.defaultLine = entry.default_line;

			actors.set(actor.id, actor);

			trace("Loaded actor: " + actor.name);
		}
	}

	/**
	 * Returns an actor by ID, or null if not found.
	 */
	public function getActorById(id:String):Null<Actor> {
		var actor = actors.get(id);
		if (actor == null) {
			trace("Warning: Actor with ID '" + id + "' not found.");
		}
		return actor;
	}

	/**
	 * Get actor for location
	 */
	public function getActorForLocation(locationId:String):Null<Actor> {
		for (actor in actors) {
			if (actor.locationId != null && actor.locationId == locationId) {
				return actor;
			}
		}
		return null;
	}
}
