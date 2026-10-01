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
			var label = task.item != null ? task.item.name : task.name;
			switch task.state {
				case Accepted:
					if (task.from != null) {
						showMarker(task.from.id, label);
					} else {
						for (loc in task.tos) {
							showMarker(loc.id, label);
						}
					}
				case PickedUp:
					for (loc in task.tos) {
						showMarker(loc.id, label);
					}
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
