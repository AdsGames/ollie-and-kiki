package game.dialogue;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import game.Palette;
import game.actor.Actor;
import game.ui.NineSlice;

// 9-slice dialogue box using a 48x48 spritesheet (3x3 grid of 16x16 tiles).
class DialogueBox extends FlxGroup {
	private static final PADDING:Int = 8;
	private static final BOX_X:Int = 0;
	private static final BOX_Y:Int = 96;
	private static final BOX_W:Int = 240;
	private static final BOX_H:Int = 64;
	private static final INNER_W:Int = BOX_W - NineSlice.TILE * 2;
	private static final PORTRAIT_SIZE:Int = 32;
	private static final PORTRAIT_X_OFFSET:Int = -10;
	private static final PORTRAIT_Y_OFFSET:Int = 7;
	private static final CHARS_PER_SEC:Float = 30.0;

	private var actorText:FlxBitmapText;
	private var contentText:FlxBitmapText;
	private var portrait:FlxSprite;

	private var fullText:String;
	private var visibleChars:Float;
	private var lastVisibleInt:Int;
	private var typing:Bool;
	private var voicePitch:Float;
	private var onVoiceChar:Null<(String, Float) -> Void>;

	public function new() {
		super();

		this.fullText = "";
		this.visibleChars = 0;
		this.lastVisibleInt = 0;
		this.typing = false;
		this.voicePitch = 1.0;
		this.onVoiceChar = null;

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
	public function show(line:DialogueLine, actor:Null<Actor>, onVoiceChar:Null<(String, Float) -> Void> = null):Void {
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
			if (ch != " " && ch != "\n" && ch != "\t") {
				onVoiceChar(ch, voicePitch);
			}
			lastVisibleInt = newInt;
		}

		contentText.text = fullText.substr(0, newInt);
	}
}
