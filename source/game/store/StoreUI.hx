package game.store;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import game.Fonts;
import game.Palette;

class StoreUI extends FlxGroup {
	static final X = 16;
	static final Y = 16;
	static final W = 208;
	static final PADDING = 8;
	static final ITEM_H = 14;

	var storeManager:StoreManager;
	var onPurchase:StoreItem->Void;
	var selectedIdx:Int = 0;
	var itemTexts:Array<FlxBitmapText> = [];
	var hintText:FlxBitmapText;

	public function new(storeManager:StoreManager) {
		super();
		this.storeManager = storeManager;
		buildUI();
		visible = false;
	}

	function buildUI():Void {
		var items = storeManager.getItems();
		var H = PADDING * 4 + 12 + items.length * ITEM_H;

		var bg = new FlxSprite(X, Y);
		bg.makeGraphic(W, H, Palette.BLACK);
		bg.scrollFactor.set(0, 0);
		add(bg);

		var title = makeText(X + PADDING, Y + PADDING, "= STORE =", Fonts.glasstownBold, Palette.YELLOW);
		add(title);

		for (i in 0...items.length) {
			var t = makeText(X + PADDING, Y + PADDING + 14 + i * ITEM_H, "", Fonts.glasstown, Palette.WHITE);
			itemTexts.push(t);
			add(t);
		}

		hintText = makeText(X + PADDING, Y + PADDING + 14 + items.length * ITEM_H, "E/Z:Buy  ESC:Close", Fonts.glasstown, Palette.DARK_GREY);
		add(hintText);
	}

	function makeText(x:Float, y:Float, text:String, font:flixel.graphics.frames.FlxBitmapFont, color:FlxColor):FlxBitmapText {
		var t = new FlxBitmapText(font);
		t.x = x;
		t.y = y;
		t.color = color;
		t.scrollFactor.set(0, 0);
		t.text = text;
		return t;
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
			return;
		}

		var items = storeManager.getItems();
		if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W) {
			selectedIdx = (selectedIdx - 1 + items.length) % items.length;
			refresh();
		} else if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S) {
			selectedIdx = (selectedIdx + 1) % items.length;
			refresh();
		} else if (FlxG.keys.justPressed.Z || FlxG.keys.justPressed.E || FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) {
			var item = items[selectedIdx];
			var purchased = storeManager.purchase(item.id);
			if (purchased != null) {
				refresh();
			}
		} else if (FlxG.keys.justPressed.ESCAPE) {
			close();
		}
	}

	function refresh():Void {
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
				itemTexts[i].color = Palette.WHITE;
			}
		}
	}
}
