package game.time;

import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import game.Fonts;
import game.Palette;
import game.event.EventBus;
import game.ui.NineSlice;
import game.ui.PanelAnimator;
import game.ui.UIText;

/**
 * End-of-day panel listing the day's deliveries and earnings.
 * Emits DaySummaryClosed when dismissed.
 */
class DaySummary extends FlxGroup {
	private static final W:Int = 144;
	private static final H:Int = 80;
	private static final X:Int = Std.int((240 - W) / 2);
	private static final Y:Int = 28;
	private static final PADDING:Int = 8;
	private static final LINE_H:Int = 12;

	// Ignore input briefly so a held key does not dismiss the panel instantly.
	private static final INPUT_DELAY:Float = 0.6;

	public var isOpen(default, null):Bool;

	private var events:EventBus;
	private var anim:PanelAnimator;
	private var titleText:FlxBitmapText;
	private var deliveriesText:FlxBitmapText;
	private var coinsText:FlxBitmapText;
	private var hintText:FlxBitmapText;
	private var openTime:Float;

	public function new(events:EventBus) {
		super();
		this.events = events;
		this.isOpen = false;
		this.openTime = 0;

		add(new NineSlice(X, Y, W, H));
		titleText = makeText(X + PADDING, Y + PADDING, Fonts.glasstownBold, Palette.DARK_GREEN);
		deliveriesText = makeText(X + PADDING, Y + PADDING + 16, Fonts.glasstown, Palette.BLACK);
		coinsText = makeText(X + PADDING, Y + PADDING + 16 + LINE_H, Fonts.glasstown, Palette.BLACK);
		hintText = makeText(X + PADDING, Y + H - PADDING - 12, Fonts.glasstown, Palette.DARK_GREY);

		visible = false;
		anim = new PanelAnimator(this, -(Y + H));
	}

	public function open(day:Int, stats:DayStats):Void {
		isOpen = true;
		openTime = 0;
		titleText.text = 'END OF DAY ${day}';
		deliveriesText.text = 'Tasks completed: ${stats.tasksCompleted}';
		coinsText.text = 'Coins earned: ${stats.coinsEarned}';
		hintText.text = '${InputManager.label(Interact)}: Start day ${day + 1}';
		anim.show();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (!isOpen) {
			return;
		}
		openTime += elapsed;
		if (openTime >= INPUT_DELAY && InputManager.justPressed(Interact)) {
			isOpen = false;
			anim.hide();
			events.emit(DaySummaryClosed);
		}
	}

	private function makeText(x:Float, y:Float, font:flixel.graphics.frames.FlxBitmapFont, color:FlxColor):FlxBitmapText {
		var t = UIText.make(x, y, "", font, color);
		add(t);
		return t;
	}
}
