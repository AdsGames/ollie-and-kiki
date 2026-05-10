package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import game.Fonts;
import game.Palette;

class MenuState extends FlxState {
	private var pressAnyKey:FlxBitmapText;
	private var blinkTimer:FlxTimer;
	private var transitioning:Bool;

	public function new() {
		super();
		transitioning = false;
	}

	override public function create():Void {
		super.create();
		FlxG.mouse.visible = true;

		FlxG.camera.fade(FlxColor.WHITE, 0.5, true);

		FlxG.sound.playMusic(AssetPaths.jazzollie__ogg, 0, true);
		FlxTween.tween(FlxG.sound.music, {volume: 0.5}, 1.5);

		add(new FlxSprite(0, 0, AssetPaths.title__png));

		pressAnyKey = new FlxBitmapText(Fonts.glasstownBold);
		pressAnyKey.text = "PRESS ANY KEY TO START";
		pressAnyKey.color = Palette.WHITE;
		pressAnyKey.scrollFactor.set(0, 0);
		pressAnyKey.x = Math.round((FlxG.width - pressAnyKey.width) / 2);
		pressAnyKey.y = FlxG.height - 18;
		add(pressAnyKey);

		blinkTimer = new FlxTimer();
		blinkTimer.start(0.55, (_) -> pressAnyKey.visible = !pressAnyKey.visible, 0);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (!transitioning && InputManager.justPressed(Any)) {
			transitioning = true;
			blinkTimer.cancel();
			FlxG.camera.fade(FlxColor.BLACK, 0.4, false, () -> FlxG.switchState(GameState.new));
		}
	}

	override public function destroy():Void {
		blinkTimer.cancel();
		super.destroy();
	}
}
