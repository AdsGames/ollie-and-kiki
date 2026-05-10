package game.actor;

import flixel.group.FlxGroup;
import game.location.LocationManager;
import game.task.TaskManager;

class ActorRenderer extends FlxGroup {
	private var markerMap:Map<String, ActorMarker>;
	private var taskManager:TaskManager;

	// Group of quest-available labels rendered above actors.
	public var questLabels:FlxGroup;

	public function new(actorManager:ActorManager, locationManager:LocationManager, taskManager:TaskManager) {
		super();
		this.taskManager = taskManager;
		markerMap = new Map();
		questLabels = new FlxGroup();

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
			questLabels.add(marker.questLabel);
			markerMap[actor.locationId] = marker;
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		for (id in markerMap.keys()) {
			markerMap[id].hideQuest();
		}

		for (task in taskManager.tasks) {
			if (taskManager.canActivate(task)) {
				var marker = markerMap[task.giverLocation.id];
				if (marker != null) {
					marker.showQuest();
				}
			}
		}
	}
}
