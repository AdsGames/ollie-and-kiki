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

			actor.x = location.x + actor.offsetX;
			actor.y = location.y + actor.offsetY;

			var marker = new ActorMarker(actor, location);
			add(marker);
			questLabels.add(marker.questLabel);
			markerMap[actor.locationId] = marker;
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		var questGivers = new Map<String, Bool>();
		for (task in taskManager.tasks) {
			if (taskManager.canActivate(task)) {
				questGivers[task.giverLocation.id] = true;
			}
		}

		for (id in markerMap.keys()) {
			var marker = markerMap[id];
			marker.setVisible(!taskManager.isLocationActorEscorting(id));
			marker.setQuest(questGivers.exists(id));
		}
	}
}
