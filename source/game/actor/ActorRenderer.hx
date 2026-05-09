package game.actor;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import game.Fonts;
import game.location.LocationManager;
import game.task.Task;
import game.task.TaskState;

class ActorRenderer extends FlxGroup {
	static final LABEL_WIDTH = 8;

	var markerMap:Map<String, ActorMarker>;
	var questMap:Map<String, FlxBitmapText>;

	public function new() {
		super();
		markerMap = new Map();
		questMap = new Map();
	}

	public function setActors(actorManager:ActorManager, locationManager:LocationManager):Void {
		clear();
		markerMap = new Map();
		questMap = new Map();

		for (actor in actorManager.actors) {
			if (actor.locationId == null) {
				continue;
			}

			var location = locationManager.getLocationById(actor.locationId);
			if (location == null) {
				continue;
			}

			var marker = new ActorMarker(actor, location);
			add(marker);
			markerMap[actor.locationId] = marker;

			var questLabel = new FlxBitmapText(Fonts.glasstownBold);
			questLabel.fieldWidth = LABEL_WIDTH;
			questLabel.alignment = CENTER;
			questLabel.color = FlxColor.YELLOW;
			questLabel.text = "!";
			questLabel.visible = false;
			questLabel.scrollFactor.set(1, 1);
			add(questLabel);
			questMap[actor.locationId] = questLabel;
		}
	}

	public function updateFromTasks(tasks:Array<Task>):Void {
		for (id in questMap.keys()) {
			questMap[id].visible = false;
		}

		for (task in tasks) {
			if (task.state == TaskState.Idle) {
				var questLabel = questMap[task.giverLocation.id];
				if (questLabel != null) {
					questLabel.visible = true;
				}
			}
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		for (id in markerMap.keys()) {
			var marker = markerMap[id];
			var questLabel = questMap[id];

			var bob = 2 * Math.sin(FlxG.game.ticks / 100);
			questLabel.x = marker.x + marker.width / 2 - LABEL_WIDTH / 2;
			questLabel.y = marker.y - questLabel.height - 2 + bob;
		}
	}
}
