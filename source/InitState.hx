package;

import flixel.FlxG;
import flixel.FlxGame;

class InitState extends FlxGame {
  public function new() {
    super(800, 600, MenuState, 60, 60, true, false);

    FlxG.sound.volume = 1.0;
  }
}
