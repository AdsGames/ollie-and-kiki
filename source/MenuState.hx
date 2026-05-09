package;

import GameState;
import flixel.FlxG;
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
		var centerX = FlxG.width / 2 - 40;
		var centerY = FlxG.height / 2;
		add(new FlxButton(centerX, centerY - 15, "Start Game", () -> FlxG.switchState(GameState.new)));
		add(new FlxButton(centerX, centerY + 5, "Instructions", () -> {}));
	}
}
