package game.actor;

import flixel.group.FlxGroup;
import game.location.LocationManager;
import game.task.TaskManager;
import game.task.TaskState;

class ActorRenderer extends FlxGroup {
	var markerMap:Map<String, ActorMarker>;
	var taskManager:TaskManager;

	public function new(actorManager:ActorManager, locationManager:LocationManager, taskManager:TaskManager) {
		super();
		this.taskManager = taskManager;
		markerMap = new Map();

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
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		for (id in markerMap.keys()) {
			markerMap[id].hideQuest();
		}

		for (task in taskManager.tasks) {
			if (task.state == TaskState.Idle) {
				var marker = markerMap[task.giverLocation.id];
				if (marker != null) {
					marker.showQuest();
				}
			}
		}
	}
}
