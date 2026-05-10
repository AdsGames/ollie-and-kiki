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
	private static final FADE_DURATION:Float = 0.35;
	private static final HOLD_DURATION:Float = 1.8;

	private var splashes:Array<String>;
	private var currentIdx:Int;
	private var sprite:FlxSprite;
	private var citySound:FlxSound;
	private var holdTimer:FlxTimer;
	private var done:Bool;

	public function new() {
		super();
		splashes = [AssetPaths.splash_adsgames__png, AssetPaths.splash_tojam__png];
		currentIdx = 0;
		done = false;
	}

	override public function create():Void {
		super.create();
		bgColor = FlxColor.WHITE;

		sprite = new FlxSprite();
		sprite.scrollFactor.set(0, 0);
		add(sprite);

		citySound = FlxG.sound.play(AssetPaths.city__ogg, 0.35, true);

		showNext();
	}

	private function showNext():Void {
		if (currentIdx >= splashes.length) {
			advance();
			return;
		}
		sprite.loadGraphic(splashes[currentIdx++]);
		sprite.screenCenter();
		sprite.alpha = 0;

		FlxTween.tween(sprite, {alpha: 1.0}, FADE_DURATION, {
			ease: FlxEase.linear,
			onComplete: (_) -> {
				holdTimer = new FlxTimer();
				holdTimer.start(HOLD_DURATION, (_) -> {
					FlxTween.tween(sprite, {alpha: 0.0}, FADE_DURATION, {
						ease: FlxEase.linear,
						onComplete: (_) -> showNext()
					});
				});
			}
		});
	}

	private function advance():Void {
		if (done) {
			return;
		}
		done = true;

		FlxTween.cancelTweensOf(sprite);
		if (holdTimer != null) {
			holdTimer.cancel();
		}
		if (citySound != null) {
			citySound.stop();
			citySound = null;
		}
		FlxG.camera.fade(FlxColor.WHITE, 0.4, false, () -> FlxG.switchState(MenuState.new));
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}

	override public function destroy():Void {
		if (citySound != null) {
			citySound.stop();
		}
		super.destroy();
	}
}
