package;

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
    add(new FlxButton(650, 380, "Start Game", () -> {}));
    add(new FlxButton(650, 420, "Instructions", () -> {}));
  }
}
