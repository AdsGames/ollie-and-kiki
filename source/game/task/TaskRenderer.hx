package game.task;

import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import game.Fonts;
import game.Palette;
import game.ui.NineSlice;

class TaskRenderer extends FlxGroup {
	// Maximum number of tasks to display at once.
	private static final MAX_TASKS:Int = 3;

	// Layout constants for the task panel.
	private static final LINE_HEIGHT:Int = 14;

	// PANEL_X offset
	private static final PANEL_X:Int = 4;

	// PANEL_Y offset
	private static final PANEL_Y:Int = 4;

	// PANEL_W width
	private static final PANEL_W:Int = 232;

	// Padding around the text inside the panel
	private static final PADDING:Int = 8;

	// Panel height calculation
	private static final PANEL_H:Int = LINE_HEIGHT + MAX_TASKS * LINE_HEIGHT + PADDING * 2;

	// All task text
	private var taskTexts:Array<FlxBitmapText>;

	// Reference to the task manager to get active tasks.
	private var taskManager:TaskManager;

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
		if (!visible) {
			return;
		}
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

	private function formatTask(task:Task):String {
		var timer = "";
		if (task.state == PickedUp && task.timeLimit != null) {
			timer = " (${task.timeRemaining()}s)";
		}

		return switch task.state {
			case Accepted: '> Pick up ${task.item.name} at ${task.from.name}';
			case PickedUp: '> Deliver ${task.item.name} to ${task.to.name}${timer}';
			default: "";
		};
	}
}
