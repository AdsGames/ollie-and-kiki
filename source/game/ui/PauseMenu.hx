package game.ui;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import game.Fonts;
import game.Palette;
import game.event.EventBus;

/**
 * Pause menu: resume, master volume, quit to title. Self-updating like StoreUI;
 * PauseOpened / PauseClosed drive the PauseState that freezes the world.
 */
class PauseMenu extends FlxGroup {
	private static final W:Int = 128;
	private static final H:Int = 76;
	private static final X:Int = Std.int((240 - W) / 2);
	private static final Y:Int = 32;
	private static final PADDING:Int = 8;
	private static final ITEM_H:Int = 12;
	private static final VOLUME_STEP:Float = 0.1;

	private static final RESUME:Int = 0;
	private static final VOLUME:Int = 1;
	private static final QUIT:Int = 2;
	private static final ITEM_COUNT:Int = 3;

	public var isOpen(default, null):Bool;

	private var events:EventBus;
	private var onQuit:() -> Void;
	private var anim:PanelAnimator;
	private var itemTexts:Array<FlxBitmapText>;
	private var hintText:FlxBitmapText;
	private var selectedIdx:Int;

	// Set once Quit is chosen; the menu stays up and ignores input while the screen fades out.
	private var quitting:Bool;

	public function new(events:EventBus, onQuit:() -> Void) {
		super();
		this.events = events;
		this.onQuit = onQuit;
		this.isOpen = false;
		this.selectedIdx = 0;
		this.quitting = false;

		add(new NineSlice(X, Y, W, H));
		add(UIText.make(X + PADDING, Y + PADDING, "PAUSED", Fonts.glasstownBold, Palette.BLACK));

		itemTexts = [];
		for (i in 0...ITEM_COUNT) {
			var t = UIText.make(X + PADDING, Y + PADDING + 14 + i * ITEM_H, "", Fonts.glasstown, Palette.BLACK);
			itemTexts.push(t);
			add(t);
		}

		hintText = UIText.make(X + PADDING, Y + H - PADDING - 12, "", Fonts.glasstown, Palette.DARK_GREY);
		add(hintText);

		visible = false;
		anim = new PanelAnimator(this, -(Y + H));
	}

	public function open():Void {
		if (isOpen) {
			return;
		}
		isOpen = true;
		selectedIdx = RESUME;
		refresh();
		anim.show();
		events.emit(PauseOpened);
	}

	public function close():Void {
		if (!isOpen) {
			return;
		}
		isOpen = false;
		anim.hide();
		events.emit(PauseClosed);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (!isOpen || quitting) {
			return;
		}

		if (InputManager.justPressed(MoveUp)) {
			selectedIdx = (selectedIdx - 1 + ITEM_COUNT) % ITEM_COUNT;
		} else if (InputManager.justPressed(MoveDown)) {
			selectedIdx = (selectedIdx + 1) % ITEM_COUNT;
		} else if (selectedIdx == VOLUME && InputManager.justPressed(MoveLeft)) {
			changeVolume(-VOLUME_STEP);
		} else if (selectedIdx == VOLUME && InputManager.justPressed(MoveRight)) {
			changeVolume(VOLUME_STEP);
		} else if (InputManager.justPressed(Interact)) {
			switch (selectedIdx) {
				case RESUME:
					close();
				case QUIT:
					quitting = true;
					onQuit();
				default:
			}
		} else if (InputManager.justPressed(Cancel) || InputManager.justPressed(Pause)) {
			close();
		}
		refresh();
	}

	private function changeVolume(delta:Float):Void {
		var volume = Math.round((FlxG.sound.volume + delta) * 10) / 10;
		FlxG.sound.volume = Math.max(0, Math.min(1, volume));
		// Same save slot flixel's sound tray uses, so it is restored on launch.
		FlxG.save.data.volume = FlxG.sound.volume;
		FlxG.save.flush();
	}

	private function refresh():Void {
		var volumePct = Math.round(FlxG.sound.volume * 100);
		var labels = ["Resume", 'Volume  < ${volumePct}% >', "Quit to Title"];
		for (i in 0...ITEM_COUNT) {
			var prefix = i == selectedIdx ? ">" : " ";
			itemTexts[i].text = '${prefix} ${labels[i]}';
			itemTexts[i].color = i == selectedIdx ? Palette.DARK_GREEN : Palette.BLACK;
		}
		hintText.text = '${InputManager.label(Interact)}:Select  ${InputManager.label(Cancel)}:Back';
	}
}
