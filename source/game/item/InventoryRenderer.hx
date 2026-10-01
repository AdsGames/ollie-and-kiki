package game.item;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import game.task.TaskManager;

class InventoryRenderer extends FlxGroup {
	private static final PADDING:Int = 4;
	private static final ICON_SIZE:Int = 16;
	private static final ICON_STEP:Int = ICON_SIZE + 4;
	private static final MAX_SLOTS:Int = 3;

	private var slots:Array<FlxSprite>;
	private var lastKey:String;
	private var taskManager:TaskManager;

	public function new(taskManager:TaskManager) {
		super();
		this.taskManager = taskManager;
		lastKey = "";

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
		var key = "";
		var carried = [];
		for (t in taskManager.tasks) {
			if (t.state == PickedUp && t.item != null) {
				key += t.item.id + ",";
				carried.push(t.item);
			}
		}
		if (key == lastKey) {
			return;
		}
		lastKey = key;

		for (i in 0...MAX_SLOTS) {
			if (i < carried.length) {
				slots[i].loadGraphic(carried[i].image);
				slots[i].setGraphicSize(ICON_SIZE, ICON_SIZE);
				slots[i].updateHitbox();
				slots[i].visible = true;
			} else {
				slots[i].visible = false;
			}
		}
	}
}
