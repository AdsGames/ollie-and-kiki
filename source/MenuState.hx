package;

import GameState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxButton;

class MenuState extends FlxState {
	public function new() {
		super();
	}

	override public function create() {
		FlxG.mouse.visible = true;

		createUI();
	}

	private function createUI() {
		add(new FlxSprite(0, 0, AssetPaths.title__png));

		var centerX = FlxG.width / 2 - 40;
		var centerY = FlxG.height / 2;
		add(new FlxButton(centerX, centerY + 10, "Start Game", () -> FlxG.switchState(GameState.new)));
		add(new FlxButton(centerX, centerY + 40, "Instructions", () -> {}));
	}
}
