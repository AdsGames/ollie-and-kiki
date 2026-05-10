package game.location;

import flixel.group.FlxGroup;
import game.task.TaskManager;

class LocationRenderer extends FlxGroup {
	private var markerMap:Map<String, LocationMarker>;
	private var taskManager:TaskManager;

	public function new(locationManager:LocationManager, taskManager:TaskManager) {
		super();
		this.taskManager = taskManager;
		markerMap = new Map();

		for (loc in locationManager.getAllLocations()) {
			var marker = new LocationMarker(loc);
			add(marker);
			markerMap[loc.id] = marker;
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		for (id in markerMap.keys()) {
			markerMap[id].hide();
		}

		for (task in taskManager.tasks) {
			switch task.state {
				case Accepted:
					showMarker(task.from.id, task.item.name);
				case PickedUp:
					showMarker(task.to.id, task.item.name);
				case Delivered:
				case Idle:
			}
		}
	}

	private function showMarker(locationId:String, text:String):Void {
		var marker = markerMap[locationId];
		if (marker == null) {
			return;
		}
		marker.show(text);
	}
}
