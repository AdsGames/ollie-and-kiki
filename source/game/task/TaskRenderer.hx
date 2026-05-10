package game.task;

import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import game.Fonts;

class TaskRenderer extends FlxGroup {
	static final MAX_TASKS = 3;
	static final LINE_HEIGHT = 12;

	var taskTexts:Array<FlxBitmapText>;
	var taskManager:TaskManager;

	public function new(taskManager:TaskManager) {
		super();
		this.taskManager = taskManager;
		taskTexts = [];
		for (i in 0...MAX_TASKS) {
			var t = new FlxBitmapText(Fonts.glasstownBold);
			t.x = 8;
			t.y = 8 + i * LINE_HEIGHT;
			t.fieldWidth = 224;
			t.multiLine = false;
			t.color = FlxColor.WHITE;
			t.scrollFactor.set(0, 0);
			t.visible = false;
			add(t);
			taskTexts.push(t);
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		var active = [for (t in taskManager.tasks) if (t.state == Accepted || t.state == PickedUp) t];
		for (i in 0...MAX_TASKS) {
			if (i < active.length) {
				taskTexts[i].visible = true;
				taskTexts[i].text = formatTask(active[i]);
				taskTexts[i].color = FlxColor.WHITE;
				if (active[i].state == PickedUp && active[i].timeLimit != null && active[i].timeRemaining() < 10) {
					taskTexts[i].color = FlxColor.RED;
				}
			} else {
				taskTexts[i].visible = false;
			}
		}
	}

	function formatTask(task:Task):String {
		return switch task.state {
			case Accepted: '> Pick up ${task.item.name} at ${task.from.name}';
			case PickedUp: '> Deliver ${task.item.name} to ${task.to.name}${formatTimer(task)}';
			default: "";
		};
	}

	function formatTimer(task:Task):String {
		if (task.timeLimit == null) {
			return "";
		}
		var secs = Math.ceil(task.timeRemaining());
		var m = Std.int(secs / 60);
		var s = secs % 60;
		return ' [${m}:${StringTools.lpad(Std.string(s), "0", 2)}]';
	}
}
