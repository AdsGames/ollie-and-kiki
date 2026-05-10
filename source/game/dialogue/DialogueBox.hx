package game.dialogue;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import game.Palette;
import game.actor.Actor;
import game.ui.NineSlice;

// 9-slice dialogue box using a 48x48 spritesheet (3x3 grid of 16x16 tiles).
class DialogueBox extends FlxGroup {
	static final PADDING = 8;
	static final BOX_X = 0;
	static final BOX_Y = 96;
	static final BOX_W = 240;
	static final BOX_H = 64;
	static final INNER_W = BOX_W - NineSlice.TILE * 2;
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

		add(new NineSlice(BOX_X, BOX_Y, BOX_W, BOX_H));

		// Portrait floats above the top-right corner of the box
		portrait = new FlxSprite(BOX_W - PORTRAIT_SIZE + PORTRAIT_X_OFFSET, BOX_Y - PORTRAIT_SIZE + PORTRAIT_Y_OFFSET);
		portrait.scrollFactor.set(0, 0);
		portrait.visible = false;
		add(portrait);

		// Actor name sits inside the top-border row
		actorText = new FlxBitmapText(Fonts.glasstownBold);
		actorText.x = BOX_X + PADDING;
		actorText.y = BOX_Y + PADDING - 2;
		actorText.color = Palette.BLACK;
		actorText.scrollFactor.set(0, 0);
		actorText.setSize(BOX_W - PADDING * 2, NineSlice.TILE - PADDING * 2);
		add(actorText);

		// Content text fills the inner area
		contentText = new FlxBitmapText(Fonts.glasstown);
		contentText.x = BOX_X + PADDING;
		contentText.y = BOX_Y + NineSlice.TILE + PADDING - 2;
		contentText.autoSize = false;
		contentText.fieldWidth = INNER_W - PADDING * 2;
		contentText.multiLine = true;
		contentText.wrap = WORD(WordSplitConditions.LINE_WIDTH);
		contentText.color = Palette.BLACK;
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

}
