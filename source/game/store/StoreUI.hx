package game.store;

import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import game.Fonts;
import game.Palette;
import game.ui.NineSlice;

class StoreUI extends FlxGroup {
	private static final X:Int = 16;
	private static final Y:Int = 16;
	private static final W:Int = 208;
	private static final PADDING:Int = 8;
	private static final ITEM_H:Int = 14;

	private var storeManager:StoreManager;
	private var selectedIdx:Int;
	private var itemTexts:Array<FlxBitmapText>;
	private var hintText:FlxBitmapText;

	public function new(storeManager:StoreManager) {
		super();

		this.selectedIdx = 0;
		this.itemTexts = [];
		this.storeManager = storeManager;
		buildUI();
		visible = false;
	}

	public function open():Void {
		storeManager.setOpen(true);
		visible = true;
		selectedIdx = 0;
		refresh();
	}

	public function close():Void {
		storeManager.setOpen(false);
		visible = false;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (!storeManager.isOpen) {
			visible = false;
			return;
		}

		var items = storeManager.getItems();
		if (InputManager.justPressed(MoveUp)) {
			selectedIdx = (selectedIdx - 1 + items.length) % items.length;
			refresh();
		} else if (InputManager.justPressed(MoveDown)) {
			selectedIdx = (selectedIdx + 1) % items.length;
			refresh();
		} else if (InputManager.justPressed(Interact)) {
			var item = items[selectedIdx];
			var purchased = storeManager.purchase(item.id);
			if (purchased != null) {
				refresh();
			}
		} else if (InputManager.justPressed(Cancel)) {
			close();
		}
	}

	private function buildUI():Void {
		var items = storeManager.getItems();
		var h = PADDING * 4 + 12 + items.length * ITEM_H;

		add(new NineSlice(X, Y, W, h));

		var title = makeText(X + PADDING, Y + PADDING, "STORE", Fonts.glasstownBold, Palette.BLACK);
		add(title);

		for (i in 0...items.length) {
			var t = makeText(X + PADDING, Y + PADDING + 14 + i * ITEM_H, "", Fonts.glasstown, Palette.BLACK);
			itemTexts.push(t);
			add(t);
		}

		hintText = makeText(X + PADDING, Y + PADDING + 14 + items.length * ITEM_H, "E/A:Buy  ESC/B:Close", Fonts.glasstown, Palette.DARK_GREY);
		add(hintText);
	}

	private function makeText(x:Float, y:Float, text:String, font:flixel.graphics.frames.FlxBitmapFont, color:FlxColor):FlxBitmapText {
		var t = new FlxBitmapText(font);
		t.x = x;
		t.y = y;
		t.color = color;
		t.scrollFactor.set(0, 0);
		t.text = text;
		return t;
	}

	private function refresh():Void {
		var items = storeManager.getItems();
		for (i in 0...items.length) {
			var item = items[i];
			var owned = storeManager.isPurchased(item.id);
			var prefix = i == selectedIdx ? ">" : " ";
			var status = owned ? "[owned]" : '${item.price}c';
			itemTexts[i].text = '${prefix} ${item.name} - ${status}';
			if (owned) {
				itemTexts[i].color = Palette.DARK_GREY;
			} else if (i == selectedIdx) {
				itemTexts[i].color = storeManager.coins >= item.price ? Palette.YELLOW : Palette.RED;
			} else {
				itemTexts[i].color = Palette.BLACK;
			}
		}
	}
}
