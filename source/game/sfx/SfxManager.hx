package game.sfx;

import flixel.FlxG;
import flixel.math.FlxRandom;
import flixel.sound.FlxSound;
import flixel.util.FlxTimer;

class SfxManager {
	static final PICKUP_SOUNDS = ["assets/sounds/sfx/three_tone_2.ogg",];

	static final DELIVER_SOUNDS = ["assets/sounds/sfx/power_up_1.ogg",];

	static final EXPIRE_SOUNDS = ["assets/sounds/sfx/space_trash_2.ogg",];

	static final TIMER_WARN_SOUNDS = ["assets/sounds/sfx/power_up_11.ogg",];

	static final SPEECH_BLIP_S = 0.06;
	static final BASE_SPEECH_PITCH = 1.5;

	public function new() {}

	public function playVoiceChar(ch:String, actorPitch:Float):Void {
		var lower = ch.toLowerCase();
		var code = lower.charCodeAt(0);

		// Invalid character, skip
		if (code < 97 || code > 122) {
			return;
		}
		var path = 'assets/sounds/speech/${lower}.ogg';
		var sound = FlxG.sound.play(path);
		if (sound != null) {
			// Some random pan to make it feel more dynamic
			sound.pan = FlxG.random.float(-0.1, 0.1);
			sound.volume = FlxG.random.float(0.5, 0.7);
			sound.pitch = BASE_SPEECH_PITCH * actorPitch;
			new FlxTimer().start(SPEECH_BLIP_S, _ -> if (sound.active) sound.stop());
		}
	}

	public function playTimerWarning():Void {
		playRandom(TIMER_WARN_SOUNDS);
	}

	public function playTaskPickup():Void {
		playRandom(PICKUP_SOUNDS);
	}

	public function playTaskDelivered():Void {
		playRandom(DELIVER_SOUNDS);
	}

	public function playTaskExpired():Void {
		playRandom(EXPIRE_SOUNDS);
	}

	function playRandom(sounds:Array<String>):Void {
		FlxG.sound.play(sounds[FlxG.random.int(0, sounds.length - 1)], 0.6);
	}
}
