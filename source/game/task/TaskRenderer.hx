package game.task;

import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import game.Fonts;
import game.Palette;
import game.ui.NineSlice;

class TaskRenderer extends FlxGroup {
	static final MAX_TASKS = 3;
	static final LINE_HEIGHT = 14;
	static final PANEL_X = 4;
	static final PANEL_Y = 4;
	static final PANEL_W = 232;
	static final PADDING = 8;
	static final PANEL_H = LINE_HEIGHT + MAX_TASKS * LINE_HEIGHT + PADDING * 2;

	var taskTexts:Array<FlxBitmapText>;
	var taskManager:TaskManager;

	public function new(taskManager:TaskManager) {
		super();
		this.taskManager = taskManager;

		add(new NineSlice(PANEL_X, PANEL_Y, PANEL_W, PANEL_H));

		var title = new FlxBitmapText(Fonts.glasstownBold);
		title.x = PANEL_X + PADDING;
		title.y = PANEL_Y + PADDING;
		title.color = Palette.DARK_GREEN;
		title.text = "QUESTS";
		title.scrollFactor.set(0, 0);
		add(title);

		taskTexts = [];
		for (i in 0...MAX_TASKS) {
			var t = new FlxBitmapText(Fonts.glasstown);
			t.x = PANEL_X + PADDING;
			t.y = PANEL_Y + PADDING + LINE_HEIGHT + i * LINE_HEIGHT;
			t.fieldWidth = PANEL_W - PADDING * 2;
			t.multiLine = false;
			t.color = Palette.BLACK;
			t.scrollFactor.set(0, 0);
			t.visible = false;
			add(t);
			taskTexts.push(t);
		}

		visible = false;
	}

	public function toggle():Void {
		visible = !visible;
	}

	override public function update(elapsed:Float):Void {
		if (!visible)
			return;
		super.update(elapsed);

		var active = [for (t in taskManager.tasks) if (t.state == Accepted || t.state == PickedUp) t];
		for (i in 0...MAX_TASKS) {
			if (i < active.length) {
				taskTexts[i].visible = true;
				taskTexts[i].text = formatTask(active[i]);
				taskTexts[i].color = active[i].state == PickedUp
					&& active[i].timeLimit != null
					&& active[i].timeRemaining() < 10 ? Palette.RED : Palette.BLACK;
			} else {
				taskTexts[i].visible = false;
			}
		}
	}

	function formatTask(task:Task):String {
		var timer = "";
		if (task.state == PickedUp && task.timeLimit != null) {
			var remaining = Std.int(task.timeRemaining());
			timer = " (${remaining}s)";
		}

		return switch task.state {
			case Accepted: '> Pick up ${task.item.name} at ${task.from.name}';
			case PickedUp: '> Deliver ${task.item.name} to ${task.to.name}${timer}';
			default: "";
		};
	}
}
