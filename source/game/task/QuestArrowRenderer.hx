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
	private static final INITIAL_ARROWS:Int = 6;
	private static final TIMER_W:Int = 28;

	private var taskManager:TaskManager;
	private var arrows:Array<FlxSprite>;
	private var timerLabels:Array<FlxBitmapText>;

	public function new(taskManager:TaskManager) {
		super();
		this.taskManager = taskManager;

		arrows = [];
		timerLabels = [];
		ensureArrows(INITIAL_ARROWS);
	}

	// Grow the arrow pool so every active target gets one.
	private function ensureArrows(count:Int):Void {
		while (arrows.length < count) {
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

		var pairs = collectPairs();
		ensureArrows(pairs.length);

		for (i in 0...arrows.length) {
			if (i >= pairs.length) {
				arrows[i].visible = false;
				timerLabels[i].visible = false;
				continue;
			}
			renderArrow(i, pairs[i].task, pairs[i].target);
		}
	}

	private function collectPairs():Array<{task:Task, target:Location}> {
		var pairs:Array<{task:Task, target:Location}> = [];
		for (task in taskManager.tasks) {
			if (task.state != Accepted && task.state != PickedUp) {
				continue;
			}
			if (task.state == Accepted && task.from != null) {
				pairs.push({task: task, target: task.from});
				continue;
			}
			// Destination phase: every uncommitted candidate gets an arrow.
			if (task.activeTo != null) {
				pairs.push({task: task, target: task.activeTo});
			} else if (task.tos.length > 0) {
				for (loc in task.tos) {
					pairs.push({task: task, target: loc});
				}
			} else {
				var fallback = taskManager.primaryDestination(task);
				if (fallback != null) {
					pairs.push({task: task, target: fallback});
				}
			}
		}
		return pairs;
	}

	private function renderArrow(i:Int, task:Task, target:Location):Void {
		var targetScreenX = target.x - FlxG.camera.scroll.x;
		var targetScreenY = target.y - FlxG.camera.scroll.y;

		var screenCX = FlxG.width * 0.5;
		var screenCY = FlxG.height * 0.5;

		var dx = targetScreenX - screenCX;
		var dy = targetScreenY - screenCY;

		if (dx == 0 && dy == 0) {
			arrows[i].visible = false;
			timerLabels[i].visible = false;
			return;
		}

		// Hide when target is already on screen
		if (Math.abs(dx) < FlxG.width * 0.5 - PADDING && Math.abs(dy) < FlxG.height * 0.5 - PADDING) {
			arrows[i].visible = false;
			timerLabels[i].visible = false;
			return;
		}

		var halfW = screenCX - PADDING;
		var halfH = screenCY - PADDING;
		var scale = Math.min(halfW / Math.abs(dx), halfH / Math.abs(dy));

		var arrowW = arrows[i].width;
		var arrowH = arrows[i].height;
		var edgeX = screenCX + dx * scale;
		var edgeY = screenCY + dy * scale;

		arrows[i].x = Math.round(edgeX - arrowW * 0.5);
		arrows[i].y = Math.round(edgeY - arrowH * 0.5);
		arrows[i].angle = Math.atan2(dy, dx) * (180.0 / Math.PI);
		arrows[i].color = task.state == PickedUp ? Palette.WHITE : Palette.YELLOW;
		arrows[i].visible = true;

		if (task.state == PickedUp && task.timeLimit != null) {
			var secs = Math.ceil(task.timeRemaining());
			var m = Std.int(secs / 60);
			var s = secs % 60;
			timerLabels[i].text = '${m}:${StringTools.lpad(Std.string(s), "0", 2)}';
			timerLabels[i].color = task.timeRemaining() < 10 ? Palette.RED : Palette.WHITE;

			var len = Math.sqrt(dx * dx + dy * dy);
			var inX = (-dx / len) * (arrowW + 3);
			var inY = (-dy / len) * (arrowH + 3);
			timerLabels[i].x = Math.round(Math.max(0, Math.min(FlxG.width - TIMER_W, edgeX + inX - TIMER_W * 0.5)));
			timerLabels[i].y = Math.round(Math.max(0, Math.min(FlxG.height - 8, edgeY + inY - 4)));
			timerLabels[i].visible = true;
		} else {
			timerLabels[i].visible = false;
		}
	}
}
