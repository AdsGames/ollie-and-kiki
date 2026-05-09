package game.dialogue;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;

// 9-slice dialogue box using a 48x48 spritesheet (3x3 grid of 16x16 tiles).
class DialogueBox extends FlxGroup {
	static final TILE = 16;
	static final BOX_X = 0;
	static final BOX_Y = 96;
	static final BOX_W = 240;
	static final BOX_H = 64;
	static final INNER_W = BOX_W - TILE * 2;
	static final INNER_H = BOX_H - TILE * 2;
	static final CHARS_PER_SEC = 30.0;

	var speakerText:FlxBitmapText;
	var contentText:FlxBitmapText;

	var fullText:String = "";
	var visibleChars:Float = 0;
	var typing:Bool = false;

	public function new() {
		super();

		buildSlices();

		var font = FlxBitmapFont.fromAngelCode(AssetPaths.glasstown__png, AssetPaths.glasstown__fnt);

		// Speaker name sits inside the top-border row
		speakerText = new FlxBitmapText(font);
		speakerText.x = BOX_X + TILE + 2;
		speakerText.y = BOX_Y + 4;
		speakerText.color = FlxColor.BLACK;
		speakerText.scrollFactor.set(0, 0);
		add(speakerText);

		// Content text fills the inner area
		contentText = new FlxBitmapText(font);
		contentText.x = BOX_X + TILE + 2;
		contentText.y = BOX_Y + TILE + 2;
		contentText.fieldWidth = INNER_W - 4;
		contentText.multiLine = true;
		contentText.wordWrap = true;
		contentText.color = FlxColor.BLACK;
		contentText.scrollFactor.set(0, 0);
		add(contentText);

		visible = false;
	}

	/**
	 * Show the dialogue box with a new line of dialogue. This will reset the typewriter effect.
	 * @param line The dialogue line to display
	 */
	public function show(line:DialogueLine):Void {
		speakerText.text = line.speaker;
		fullText = line.text;
		visibleChars = 0;
		typing = true;
		contentText.text = "";
		visible = true;
	}

	/**
	 * Advances the dialogue text. If the text is still typing, it will complete immediately.
	 * @return True if text was still typing (now completed). False means caller should advance to next line.
	 */
	public function advance():Bool {
		if (typing) {
			visibleChars = fullText.length;
			contentText.text = fullText;
			typing = false;
			return true;
		}
		return false;
	}

	/**
	 * Hide the dialogue box.
	 */
	public function hide():Void {
		visible = false;
	}

	/**
	 * Handle typewriter effect.
	 * @param elapsed 
	 */
	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (!visible || !typing) {
			return;
		}

		visibleChars += elapsed * CHARS_PER_SEC;
		if (visibleChars >= fullText.length) {
			visibleChars = fullText.length;
			typing = false;
		}
		contentText.text = fullText.substr(0, Std.int(visibleChars));
	}

	/**
	 * Builds the 9 slice associated with a dialog box.
	 */
	function buildSlices():Void {
		var midX = BOX_X + TILE;
		var midY = BOX_Y + TILE;
		var botY = BOX_Y + TILE + INNER_H;

		addSlice(0, BOX_X, BOX_Y, TILE, TILE);
		addSlice(1, midX, BOX_Y, INNER_W, TILE);
		addSlice(2, BOX_X + BOX_W - TILE, BOX_Y, TILE, TILE);

		addSlice(3, BOX_X, midY, TILE, INNER_H);
		addSlice(4, midX, midY, INNER_W, INNER_H);
		addSlice(5, BOX_X + BOX_W - TILE, midY, TILE, INNER_H);

		addSlice(6, BOX_X, botY, TILE, TILE);
		addSlice(7, midX, botY, INNER_W, TILE);
		addSlice(8, BOX_X + BOX_W - TILE, botY, TILE, TILE);
	}

	/**
	 * Helper for adding a single slice from the spritesheet. The frame index corresponds to the 3x3 grid of tiles.
	 * @param frameIdx The index of the tile in the 3x3 grid (0-8)
	 * @param x X position to place the slice
	 * @param y Y position to place the slice
	 * @param w Width to stretch the slice to
	 * @param h Height to stretch the slice to
	 */
	function addSlice(frameIdx:Int, x:Float, y:Float, w:Float, h:Float):Void {
		var s = new FlxSprite(x, y);
		s.loadGraphic(AssetPaths.dialogue__png, true, TILE, TILE);
		s.animation.frameIndex = frameIdx;
		s.setGraphicSize(Std.int(w), Std.int(h));
		s.updateHitbox();
		s.scrollFactor.set(0, 0);
		add(s);
	}
}
