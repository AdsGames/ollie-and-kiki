package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import game.Fonts;
import game.Palette;

/**
 * Scrolling credits. Returns to the title when the roll ends or on Interact / Cancel.
 */
class CreditsState extends FlxState {
	private static final SCROLL_SPEED:Float = 14.0;
	private static final LINE_H:Int = 12;

	// Lines starting with "#" are headings.
	private static final LINES:Array<String> = [
		"#KIKI'S DELIVERY DAY",
		"",
		"#A.D.S. GAMES",
		"Allan Legemaate",
		"Natasha Djurdjevic",
		"",
		"#MADE FOR",
		"TOJam",
		"",
		"#BUILT WITH",
		"HaxeFlixel",
		"",
		"",
		"Thanks for playing!",
	];

	private var texts:Array<FlxBitmapText>;
	private var leaving:Bool;

	override public function create():Void {
		super.create();
		bgColor = FlxColor.BLACK;
		leaving = false;
		texts = [];

		for (i in 0...LINES.length) {
			var line = LINES[i];
			var heading = StringTools.startsWith(line, "#");
			var t = new FlxBitmapText(heading ? Fonts.glasstownBold : Fonts.glasstown);
			t.text = heading ? line.substr(1) : line;
			t.color = heading ? Palette.YELLOW : Palette.WHITE;
			t.scrollFactor.set(0, 0);
			t.x = Math.round((FlxG.width - t.width) / 2);
			t.y = FlxG.height + i * LINE_H;
			texts.push(t);
			add(t);
		}

		FlxG.camera.fade(FlxColor.BLACK, 0.4, true);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (leaving) {
			return;
		}

		for (t in texts) {
			t.y -= SCROLL_SPEED * elapsed;
		}

		var last = texts[texts.length - 1];
		var rollDone = last.y < (FlxG.height - LINE_H) / 2;
		if (rollDone || InputManager.justPressed(Interact) || InputManager.justPressed(Cancel)) {
			leaving = true;
			var delay = rollDone ? 2.0 : 0.0;
			new FlxTimer().start(delay + 0.01, (_) -> FlxG.camera.fade(FlxColor.BLACK, 0.4, false, () -> FlxG.switchState(MenuState.new)));
		}
	}
}
