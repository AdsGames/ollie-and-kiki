package game.item;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import game.Fonts;
import game.task.Task;

/** HUD strip that shows which items Kiki is currently carrying. */
class InventoryRenderer extends FlxGroup {
	static final Y = 48;
	static final MAX_SLOTS = 3;
	static final ICON_SIZE = 8;
	static final ICON_STEP = ICON_SIZE + 4;
	static final LABEL_WIDTH = 28;

	var bagText:FlxBitmapText;
	var slots:Array<FlxSprite>;
	var lastKey:String = "";

	public function new() {
		super();

		bagText = new FlxBitmapText(Fonts.glasstown);
		bagText.x = 8;
		bagText.y = Y;
		bagText.fieldWidth = LABEL_WIDTH;
		bagText.multiLine = false;
		bagText.color = FlxColor.YELLOW;
		bagText.scrollFactor.set(0, 0);
		bagText.text = "Bag:";
		bagText.visible = false;
		add(bagText);

		slots = [];
		for (i in 0...MAX_SLOTS) {
			var s = new FlxSprite(8 + LABEL_WIDTH + i * ICON_STEP, Y);
			s.scrollFactor.set(0, 0);
			s.visible = false;
			add(s);
			slots.push(s);
		}
	}

	public function updateFromTasks(tasks:Array<Task>):Void {
		var carried = [for (t in tasks) if (t.state == PickedUp) t.item];
		var key = [for (item in carried) item.id].join(",");
		if (key == lastKey) {
			return;
		}
		lastKey = key;

		var hasItems = carried.length > 0;
		bagText.visible = hasItems;

		for (i in 0...MAX_SLOTS) {
			if (i < carried.length) {
				slots[i].loadGraphic(carried[i].image);
				slots[i].visible = true;
			} else {
				slots[i].visible = false;
			}
		}
	}
}
