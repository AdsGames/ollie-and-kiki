package game.ambience;

import flixel.sound.FlxSound;
import openfl.Assets;

class AmbienceManager {
	static inline final K = 3;
	static inline final MAX_RADIUS = 400.0;
	static inline final POWER = 2.0;
	static inline final AMBIENCE_GAIN = 1.5;

	public var ambiences:Map<String, Ambience>;

	var warnedIds:Map<String, Bool> = [];

	public function new() {
		ambiences = new Map();
	}

	/**
	 * Loads ambiences from a JSON file and populates the ambiences map.
	 */
	public function loadAmbiences():Void {
		var raw = Assets.getText(AssetPaths.ambience__json);
		var data:Array<{
			id:String,
			file:String,
			gain:Float,
		}> = haxe.Json.parse(raw);

		for (entry in data) {
			var ambience = new Ambience();

			if (!Assets.exists(entry.file)) {
				trace('Warning: ambience "${entry.id}" missing file "${entry.file}", ignoring.');
				warnedIds.set(entry.id, true);
				continue;
			}

			var sound = new FlxSound();
			sound.loadEmbedded(entry.file, true);
			sound.volume = 0;
			sound.play();
			ambience.sound = sound;
			ambience.id = entry.id;
			ambience.gain = entry.gain;
			ambiences.set(ambience.id, ambience);

			trace('Loaded ambience: ' + ambience.id);
		}
	}

	public function update(playerX:Float, playerY:Float, zones:Array<AmbienceZone>):Void {
		for (a in ambiences) {
			a.sound.volume = 0;
		}

		var candidates:Array<{ambience:Ambience, dist:Float}> = [];
		for (zone in zones) {
			var a = ambiences.get(zone.id);
			if (a == null) {
				if (!warnedIds.exists(zone.id)) {
					trace('Warning: no ambience loaded for zone "${zone.id}", skipping.');
					warnedIds.set(zone.id, true);
				}
				continue;
			}
			var dx = playerX - zone.x;
			var dy = playerY - zone.y;
			var dist = Math.sqrt(dx * dx + dy * dy);
			if (dist <= MAX_RADIUS) {
				candidates.push({ambience: a, dist: Math.max(dist, 1.0)});
			}
		}

		if (candidates.length == 0) {
			return;
		}

		candidates.sort((a, b) -> a.dist < b.dist ? -1 : 1);
		if (candidates.length > K) {
			candidates = candidates.slice(0, K);
		}

		var totalWeight = 0.0;
		var weights:Array<Float> = [];
		for (c in candidates) {
			var w = 1.0 / Math.pow(c.dist, POWER);
			weights.push(w);
			totalWeight += w;
		}

		// Mix ambience based on weight (inverse of distance), sample gain, and base gain.
		for (i in 0...candidates.length) {
			candidates[i].ambience.sound.volume = (weights[i] / totalWeight) * candidates[i].ambience.gain * AMBIENCE_GAIN;
		}
	}
}
