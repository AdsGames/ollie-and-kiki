package game.store;

import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import game.Fonts;
import game.Palette;
import game.ui.NineSlice;
import game.ui.PanelAnimator;
import game.ui.UIText;

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
	private var anim:PanelAnimator;

	public function new(storeManager:StoreManager) {
		super();

		this.selectedIdx = 0;
		this.itemTexts = [];
		this.storeManager = storeManager;
		var h = buildUI();
		visible = false;
		anim = new PanelAnimator(this, -(Y + h));
	}

	public function open():Void {
		storeManager.setOpen(true);
		selectedIdx = 0;
		refresh();
		anim.show();
	}

	public function close():Void {
		storeManager.setOpen(false);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (!storeManager.isOpen) {
			// Purchases close the store through StoreManager, so follow its state here.
			anim.hide();
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

	private function buildUI():Int {
		var items = storeManager.getItems();
		var h = PADDING * 4 + 12 + items.length * ITEM_H;

		add(new NineSlice(X, Y, W, h));

		var title = UIText.make(X + PADDING, Y + PADDING, "STORE", Fonts.glasstownBold, Palette.BLACK);
		add(title);

		for (i in 0...items.length) {
			var t = UIText.make(X + PADDING, Y + PADDING + 14 + i * ITEM_H, "", Fonts.glasstown, Palette.BLACK);
			itemTexts.push(t);
			add(t);
		}

		hintText = UIText.make(X + PADDING, Y + PADDING + 14 + items.length * ITEM_H, "", Fonts.glasstown, Palette.DARK_GREY);
		add(hintText);
		return h;
	}

	private function refresh():Void {
		hintText.text = '${InputManager.label(Interact)}:Buy  ${InputManager.label(Cancel)}:Close';
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
