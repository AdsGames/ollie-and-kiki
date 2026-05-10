package game.task;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import game.Fonts;
import game.Palette;
import game.location.Location;

class QuestArrowRenderer extends FlxGroup {
	private static final PADDING:Int = 12;
	private static final MAX_ARROWS:Int = 3;
	private static final TIMER_W:Int = 28;

	private var taskManager:TaskManager;
	private var arrows:Array<FlxSprite>;
	private var timerLabels:Array<FlxBitmapText>;

	public function new(taskManager:TaskManager) {
		super();
		this.taskManager = taskManager;

		arrows = [];
		timerLabels = [];
		for (_ in 0...MAX_ARROWS) {
			var arrow = new FlxSprite(0, 0, AssetPaths.arrow__png);
			arrow.scrollFactor.set(0, 0);
			arrow.visible = false;
			arrows.push(arrow);
			add(arrow);

			var label = new FlxBitmapText(Fonts.glasstownBold);
			label.fieldWidth = TIMER_W;
			label.alignment = CENTER;
			label.scrollFactor.set(0, 0);
			label.visible = false;
			timerLabels.push(label);
			add(label);
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		var activeTasks:Array<Task> = [];
		for (task in taskManager.tasks) {
			if (task.state == Accepted || task.state == PickedUp) {
				activeTasks.push(task);
			}
		}

		for (i in 0...MAX_ARROWS) {
			if (i >= activeTasks.length) {
				arrows[i].visible = false;
				timerLabels[i].visible = false;
				continue;
			}

			var task = activeTasks[i];
			var target:Location = task.state == Accepted ? task.from : task.to;

			var targetScreenX = target.x - FlxG.camera.scroll.x;
			var targetScreenY = target.y - FlxG.camera.scroll.y;

			var screenCX = FlxG.width * 0.5;
			var screenCY = FlxG.height * 0.5;

			var dx = targetScreenX - screenCX;
			var dy = targetScreenY - screenCY;

			if (dx == 0 && dy == 0) {
				arrows[i].visible = false;
				timerLabels[i].visible = false;
				continue;
			}

			// Hide when target is already on screen
			if (Math.abs(dx) < FlxG.width * 0.5 - PADDING && Math.abs(dy) < FlxG.height * 0.5 - PADDING) {
				arrows[i].visible = false;
				timerLabels[i].visible = false;
				continue;
			}

			var halfW = screenCX - PADDING;
			var halfH = screenCY - PADDING;
			var scale = Math.min(halfW / Math.abs(dx), halfH / Math.abs(dy));

			var arrowW = arrows[i].width;
			var arrowH = arrows[i].height;
			var edgeX = screenCX + dx * scale;
			var edgeY = screenCY + dy * scale;

			arrows[i].x = edgeX - arrowW * 0.5;
			arrows[i].y = edgeY - arrowH * 0.5;
			arrows[i].angle = Math.atan2(dy, dx) * (180.0 / Math.PI);
			arrows[i].color = task.state == PickedUp ? Palette.WHITE : Palette.YELLOW;
			arrows[i].visible = true;

			// Timer label: only for timed tasks in PickedUp state
			if (task.state == PickedUp && task.timeLimit != null) {
				var secs = Math.ceil(task.timeRemaining());
				var m = Std.int(secs / 60);
				var s = secs % 60;
				timerLabels[i].text = '${m}:${StringTools.lpad(Std.string(s), "0", 2)}';
				timerLabels[i].color = task.timeRemaining() < 10 ? Palette.RED : Palette.WHITE;

				// Shift label inward from edge toward screen center
				var len = Math.sqrt(dx * dx + dy * dy);
				var inX = (-dx / len) * (arrowW + 3);
				var inY = (-dy / len) * (arrowH + 3);
				timerLabels[i].x = Math.max(0, Math.min(FlxG.width - TIMER_W, edgeX + inX - TIMER_W * 0.5));
				timerLabels[i].y = Math.max(0, Math.min(FlxG.height - 8, edgeY + inY - 4));
				timerLabels[i].visible = true;
			} else {
				timerLabels[i].visible = false;
			}
		}
	}
}
