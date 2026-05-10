package game.item;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import game.task.TaskManager;

class InventoryRenderer extends FlxGroup {
	static final PADDING = 4;
	static final ICON_SIZE = 16;
	static final ICON_STEP = ICON_SIZE + 4;
	static final MAX_SLOTS = 3;

	var slots:Array<FlxSprite>;
	var lastKey:String = "";
	var taskManager:TaskManager;

	public function new(taskManager:TaskManager) {
		super();
		this.taskManager = taskManager;

		slots = [];
		for (i in 0...MAX_SLOTS) {
			var s = new FlxSprite(0, 0);
			s.x = FlxG.width - PADDING - (MAX_SLOTS - i) * ICON_STEP;
			s.y = FlxG.height - PADDING - ICON_SIZE;
			s.scrollFactor.set(0, 0);
			s.visible = false;
			add(s);
			slots.push(s);
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		var carried = [for (t in taskManager.tasks) if (t.state == PickedUp) t.item];
		var key = [for (item in carried) item.id].join(",");
		if (key == lastKey) {
			return;
		}
		lastKey = key;

		for (i in 0...MAX_SLOTS) {
			if (i < carried.length) {
				slots[i].loadGraphic(carried[i].image);
				slots[i].scale.set(ICON_SIZE / carried[i].image.width, ICON_SIZE / carried[i].image.height);
				slots[i].visible = true;
			} else {
				slots[i].visible = false;
			}
		}
	}
}
