package game.sfx;

import flixel.FlxG;
import flixel.util.FlxTimer;

class SfxManager {
	private static final SPEECH_BLIP_S:Float = 0.06;
	private static final BASE_SPEECH_PITCH:Float = 1.5;

	public function new() {}

	public function playVoiceChar(ch:String, actorPitch:Float):Void {
		var lower = ch.toLowerCase();
		var code = lower.charCodeAt(0);

		// Invalid character, skip
		if (code < 97 || code > 122) {
			return;
		}
		var path = 'assets/sounds/speech/${lower}.ogg';
		// Finished sounds are recycled for later plays, so only cut this blip if it is still ours.
		var finished = false;
		var sound = FlxG.sound.play(path, 1.0, false, null, true, () -> finished = true);
		if (sound != null) {
			// Some random pan to make it feel more dynamic
			sound.pan = FlxG.random.float(-0.1, 0.1);
			sound.volume = FlxG.random.float(0.5, 0.7);
			sound.pitch = BASE_SPEECH_PITCH * actorPitch;
			new FlxTimer().start(SPEECH_BLIP_S, _ -> if (!finished && sound.active) sound.stop());
		}
	}

	public function playTimerWarning():Void {
		FlxG.sound.play(AssetPaths.power_up_11__ogg, 0.5);
	}

	public function playTaskPickup():Void {
		FlxG.sound.play(AssetPaths.three_tone_2__ogg, 0.3);
	}

	public function playTaskDelivered():Void {
		FlxG.sound.play(AssetPaths.power_up_1__ogg, 0.3);
	}

	public function playTaskExpired():Void {
		FlxG.sound.play(AssetPaths.space_trash_2__ogg, 0.6);
	}

	public function playCameraShutter():Void {
		FlxG.sound.play(AssetPaths.camera_shutter__ogg, 0.7);
	}
}
