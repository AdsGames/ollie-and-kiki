package game.task;

import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import game.Fonts;
import game.Palette;
import game.ui.NineSlice;
import game.ui.PanelAnimator;

class TaskRenderer extends FlxGroup {
	// Maximum number of rows to display at once. The last row becomes "+N more" on overflow.
	private static final MAX_TASKS:Int = 5;

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

	private var anim:PanelAnimator;

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
		anim = new PanelAnimator(this, -(PANEL_Y + PANEL_H));
	}

	public function toggle():Void {
		anim.toggle();
	}

	override public function update(elapsed:Float):Void {
		if (!visible) {
			return;
		}
		super.update(elapsed);

		var active = [for (t in taskManager.tasks) if (t.state == Accepted || t.state == PickedUp) t];
		var overflow = active.length > MAX_TASKS;
		var shown = overflow ? MAX_TASKS - 1 : active.length;
		for (i in 0...MAX_TASKS) {
			if (overflow && i == MAX_TASKS - 1) {
				taskTexts[i].visible = true;
				taskTexts[i].text = '  +${active.length - shown} more';
				taskTexts[i].color = Palette.DARK_GREY;
			} else if (i < shown) {
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
			timer = " (${Math.ceil(task.timeRemaining())}s)";
		}

		var destName = destinationLabel(task);
		return switch [task.type, task.state] {
			case [Delivery, Accepted]: '> Pick up ${task.item.name} at ${task.from.name}';
			case [Delivery, PickedUp]: '> Deliver ${task.item.name} to ${destName}${timer}';
			case [Escort, Accepted]: '> Meet at ${task.from.name}';
			case [Escort, PickedUp]: '> Escort to ${destName}${timer}';
			case [Find, _]: '> Find ${destName}';
			case [Photo, _]: '> Snap a photo at ${destName}';
			default: "";
		};
	}

	private function destinationLabel(task:Task):String {
		if (task.tos.length == 0) {
			return "?";
		}
		if (task.tos.length == 1) {
			return task.tos[0].name;
		}
		return [for (l in task.tos) l.name].join(" or ");
	}
}
