package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.sound.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class SplashState extends FlxState {
	static final FADE_DURATION = 0.35;
	static final HOLD_DURATION = 1.8;

	var splashes = [AssetPaths.splash_adsgames__png, AssetPaths.splash_tojam__png];
	var currentIdx:Int = 0;
	var sprite:FlxSprite;
	var citySound:FlxSound;
	var done:Bool = false;

	override public function create():Void {
		super.create();
		bgColor = FlxColor.WHITE;

		sprite = new FlxSprite();
		sprite.scrollFactor.set(0, 0);
		add(sprite);

		citySound = FlxG.sound.play("assets/sounds/ambience/city.ogg", 0.35, true);

		showNext();
	}

	function showNext():Void {
		if (currentIdx >= splashes.length) {
			advance();
			return;
		}
		sprite.loadGraphic(splashes[currentIdx++]);
		sprite.screenCenter();
		sprite.alpha = 0;

		FlxTween.tween(sprite, {alpha: 1.0}, FADE_DURATION, {
			ease: FlxEase.linear,
			onComplete: (_) -> new FlxTimer().start(HOLD_DURATION, (_) -> {
				FlxTween.tween(sprite, {alpha: 0.0}, FADE_DURATION, {
					ease: FlxEase.linear,
					onComplete: (_) -> showNext()
				});
			})
		});
	}

	function advance():Void {
		if (done) return;
		done = true;
		FlxTween.cancelTweensOf(sprite);
		if (citySound != null) citySound.stop();
		FlxG.camera.fade(FlxColor.WHITE, 0.4, false, () -> FlxG.switchState(MenuState.new));
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (!done && FlxG.keys.justPressed.ANY) advance();
	}

	override public function destroy():Void {
		if (citySound != null) citySound.stop();
		super.destroy();
	}
}
