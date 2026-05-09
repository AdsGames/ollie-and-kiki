package game.task;

import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import game.Fonts;
import game.task.Task;

class TaskRenderer extends FlxGroup {
	static final MAX_TASKS = 3;
	static final LINE_HEIGHT = 12;

	var taskTexts:Array<FlxBitmapText>;

	public function new() {
		super();
		taskTexts = [];
		for (i in 0...MAX_TASKS) {
			var t = new FlxBitmapText(Fonts.glasstown);
			t.x = 8;
			t.y = 8 + i * LINE_HEIGHT;
			t.fieldWidth = 220;
			t.multiLine = false;
			t.color = FlxColor.WHITE;
			t.scrollFactor.set(0, 0);
			t.visible = false;
			add(t);
			taskTexts.push(t);
		}
	}

	public function updateTasks(tasks:Array<Task>):Void {
		var active = [for (t in tasks) if (t.state == Accepted || t.state == PickedUp) t];
		for (i in 0...MAX_TASKS) {
			if (i < active.length) {
				taskTexts[i].text = formatTask(active[i]);
				taskTexts[i].visible = true;
			} else {
				taskTexts[i].visible = false;
			}
		}
	}

	function formatTask(task:Task):String {
		return switch task.state {
			case Accepted: '> Pick up ${task.item.name} at ${task.from.name}';
			case PickedUp: '> Deliver ${task.item.name} to ${task.to.name}';
			default: "";
		};
	}
}
