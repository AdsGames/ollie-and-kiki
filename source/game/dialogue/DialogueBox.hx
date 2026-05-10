package game.dialogue;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import game.actor.Actor;

// 9-slice dialogue box using a 48x48 spritesheet (3x3 grid of 16x16 tiles).
class DialogueBox extends FlxGroup {
	static final TILE = 16;
	static final PADDING = 8;
	static final BOX_X = 0;
	static final BOX_Y = 96;
	static final BOX_W = 240;
	static final BOX_H = 64;
	static final INNER_W = BOX_W - TILE * 2;
	static final INNER_H = BOX_H - TILE * 2;
	static final PORTRAIT_SIZE = 32;
	static final PORTRAIT_X_OFFSET = -10;
	static final PORTRAIT_Y_OFFSET = 7;
	static final CHARS_PER_SEC = 30.0;

	var actorText:FlxBitmapText;
	var contentText:FlxBitmapText;
	var portrait:FlxSprite;

	var fullText:String = "";
	var visibleChars:Float = 0;
	var lastVisibleInt:Int = 0;
	var typing:Bool = false;
	var voicePitch:Float = 1.0;
	var onVoiceChar:Null<(String, Float)->Void> = null;

	public function new() {
		super();

		buildSlices();

		// Portrait floats above the top-right corner of the box
		portrait = new FlxSprite(BOX_W - PORTRAIT_SIZE + PORTRAIT_X_OFFSET, BOX_Y - PORTRAIT_SIZE + PORTRAIT_Y_OFFSET);
		portrait.scrollFactor.set(0, 0);
		portrait.visible = false;
		add(portrait);

		// Actor name sits inside the top-border row
		actorText = new FlxBitmapText(Fonts.glasstownBold);
		actorText.x = BOX_X + PADDING;
		actorText.y = BOX_Y + PADDING - 2;
		actorText.color = FlxColor.BLACK;
		actorText.scrollFactor.set(0, 0);
		actorText.setSize(BOX_W - PADDING * 2, TILE - PADDING * 2);
		add(actorText);

		// Content text fills the inner area
		contentText = new FlxBitmapText(Fonts.glasstown);
		contentText.x = BOX_X + PADDING;
		contentText.y = BOX_Y + TILE + PADDING - 2;
		contentText.autoSize = false;
		contentText.fieldWidth = INNER_W - PADDING * 2;
		contentText.multiLine = true;
		contentText.wrap = WORD(WordSplitConditions.LINE_WIDTH);
		contentText.color = FlxColor.BLACK;
		contentText.scrollFactor.set(0, 0);
		add(contentText);

		visible = false;
	}

	/**
	 * Show the dialogue box with a new line of dialogue. This will reset the typewriter effect.
	 * @param line The dialogue line to display
	 * @param actor Resolved actor for this line, or null if unknown.
	 */
	public function show(line:DialogueLine, actor:Null<Actor>, onVoiceChar:Null<(String, Float)->Void> = null):Void {
		actorText.text = actor != null ? actor.name : line.actorId;
		fullText = line.text;
		visibleChars = 0;
		lastVisibleInt = 0;
		typing = true;
		contentText.text = "";
		visible = true;
		this.voicePitch = actor != null ? actor.voicePitch : 1.0;
		this.onVoiceChar = onVoiceChar;

		if (actor != null) {
			portrait.loadGraphic(actor.imageProfile);
			portrait.setGraphicSize(PORTRAIT_SIZE, PORTRAIT_SIZE);
			portrait.updateHitbox();
			portrait.visible = true;
		} else {
			portrait.visible = false;
		}
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
		portrait.visible = false;
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

		var newInt = Std.int(visibleChars);
		if (newInt > lastVisibleInt && onVoiceChar != null) {
			var ch = fullText.charAt(newInt - 1);
			if (ch != ' ' && ch != '\n' && ch != '\t') {
				onVoiceChar(ch, voicePitch);
			}
			lastVisibleInt = newInt;
		}

		contentText.text = fullText.substr(0, newInt);
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
