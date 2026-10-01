package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import game.Fonts;
import game.Palette;
import game.save.SaveManager;

enum MenuOption {
	Continue;
	NewGame;
	Credits;
}

class MenuState extends FlxState {
	private static final LINE_H:Int = 11;

	private var options:Array<MenuOption>;
	private var optionTexts:Array<FlxBitmapText>;
	private var selectedIdx:Int;
	private var transitioning:Bool;
	private var ready:Bool;

	// New Game over an existing save needs a second press to confirm.
	private var confirmNewGame:Bool;

	public function new() {
		super();
		transitioning = false;
		ready = false;
		confirmNewGame = false;
		selectedIdx = 0;
	}

	override public function create():Void {
		super.create();
		FlxG.mouse.visible = true;

		// Drop the in-game day/night shader when returning from the game.
		FlxG.game.setFilters([]);

		FlxG.camera.fade(FlxColor.BLACK, 0.5, true, () -> ready = true);

		if (FlxG.sound.music == null || !FlxG.sound.music.playing) {
			FlxG.sound.playMusic(AssetPaths.jazzollie__ogg, 0, true);
		}
		FlxTween.cancelTweensOf(FlxG.sound.music);
		FlxTween.tween(FlxG.sound.music, {volume: 0.5}, 1.5);

		add(new FlxSprite(0, 0, AssetPaths.title__png));

		options = SaveManager.hasSave() ? [Continue, NewGame, Credits] : [NewGame, Credits];
		optionTexts = [];
		for (i in 0...options.length) {
			var t = new FlxBitmapText(Fonts.glasstownBold);
			t.scrollFactor.set(0, 0);
			t.y = FlxG.height - 8 - (options.length - i) * LINE_H;
			optionTexts.push(t);
			add(t);
		}
		refresh();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (!ready || transitioning) {
			return;
		}

		if (InputManager.justPressed(MoveUp)) {
			selectedIdx = (selectedIdx - 1 + options.length) % options.length;
			confirmNewGame = false;
			refresh();
		} else if (InputManager.justPressed(MoveDown)) {
			selectedIdx = (selectedIdx + 1) % options.length;
			confirmNewGame = false;
			refresh();
		} else if (InputManager.justPressed(Interact)) {
			select(options[selectedIdx]);
		}
	}

	private function select(option:MenuOption):Void {
		switch (option) {
			case Continue:
				startGame();
			case NewGame:
				if (SaveManager.hasSave() && !confirmNewGame) {
					confirmNewGame = true;
					refresh();
					return;
				}
				SaveManager.clear();
				startGame();
			case Credits:
				transitioning = true;
				FlxG.camera.fade(FlxColor.BLACK, 0.4, false, () -> FlxG.switchState(CreditsState.new));
		}
	}

	private function startGame():Void {
		transitioning = true;
		FlxG.camera.fade(FlxColor.BLACK, 0.4, false, () -> FlxG.switchState(GameState.new));
	}

	private function refresh():Void {
		for (i in 0...options.length) {
			var t = optionTexts[i];
			var label = switch (options[i]) {
				case Continue: "CONTINUE";
				case NewGame: confirmNewGame ? "ERASE SAVE? PRESS AGAIN" : "NEW GAME";
				case Credits: "CREDITS";
			}
			var selected = i == selectedIdx;
			t.text = selected ? '> ${label} <' : label;
			t.color = selected ? Palette.YELLOW : Palette.WHITE;
			t.x = Math.round((FlxG.width - t.width) / 2);
		}
	}
}
