package game.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import game.Fonts;
import game.Palette;
import openfl.geom.Rectangle;

/**
 * Small world-space bubble with a button label (e.g. "E" or "A"), shown over
 * whatever the player would interact with.
 */
class InteractPrompt extends FlxGroup {
	private static final H:Int = 11;
	private static final PAD_X:Int = 2;

	// Bitmap font glyphs sit below the text box top; pull the text up to centre caps in the bubble.
	private static final TEXT_Y_OFFSET:Int = -4;

	private var bubble:FlxSprite;
	private var label:FlxBitmapText;
	private var currentText:String;

	public function new() {
		super();
		currentText = "";

		bubble = new FlxSprite();
		bubble.scrollFactor.set(1, 1);
		add(bubble);

		label = new FlxBitmapText(Fonts.glasstownBold);
		label.color = Palette.BLACK;
		label.scrollFactor.set(1, 1);
		add(label);

		visible = false;
	}

	/**
	 * Show the bubble with its bottom-left corner at (x, y) in world space.
	 */
	public function showAt(x:Float, y:Float, text:String):Void {
		if (text != currentText) {
			currentText = text;
			label.text = text;
			var w = Std.int(label.width) + PAD_X * 2 - 2;
			bubble.makeGraphic(w, H, Palette.BLACK, true);
			bubble.pixels.fillRect(new Rectangle(1, 1, w - 2, H - 2), Palette.WHITE);
			bubble.dirty = true;
		}

		// Gentle bob, quantized to whole pixels
		var bob = Math.round(Math.sin(FlxG.game.ticks / 150));
		bubble.x = Math.round(x);
		bubble.y = Math.round(y - H) + bob;
		label.x = bubble.x + PAD_X - 1;
		label.y = bubble.y + TEXT_Y_OFFSET;
		visible = true;
	}

	public function hide():Void {
		visible = false;
	}
}
