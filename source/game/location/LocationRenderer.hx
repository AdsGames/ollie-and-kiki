package game.location;

import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import game.Fonts;
import game.task.Task;

class LocationRenderer extends FlxGroup {
	static final LABEL_WIDTH = 56;

	var markerMap:Map<String, LocationMarker>;
	var labelMap:Map<String, FlxBitmapText>;

	public function new() {
		super();
		markerMap = new Map();
		labelMap = new Map();
	}

	public function setLocations(locations:Array<Location>):Void {
		clear();
		markerMap = new Map();
		labelMap = new Map();

		for (loc in locations) {
			var marker = new LocationMarker(loc);
			marker.visible = false;
			add(marker);
			markerMap[loc.id] = marker;

			var label = new FlxBitmapText(Fonts.glasstown);
			label.fieldWidth = LABEL_WIDTH;
			label.multiLine = true;
			label.alignment = CENTER;
			label.color = FlxColor.WHITE;
			label.scrollFactor.set(1, 1);
			label.visible = false;
			add(label);
			labelMap[loc.id] = label;
		}
	}

	public function updateFromTasks(tasks:Array<Task>):Void {
		for (id in markerMap.keys()) {
			markerMap[id].visible = false;
			labelMap[id].visible = false;
		}

		for (task in tasks) {
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

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		for (id in markerMap.keys()) {
			var marker = markerMap[id];
			var label = labelMap[id];
			if (!label.visible)
				continue;
			if (marker.visible) {
				label.x = marker.x + marker.width / 2 - LABEL_WIDTH / 2;
				label.y = marker.y - label.height - 2;
			} else {
				label.x = marker.location.x + marker.width / 2 - LABEL_WIDTH / 2;
				label.y = marker.location.y - label.height - 2;
			}
		}
	}

	function showMarker(locationId:String, text:String):Void {
		var marker = markerMap[locationId];
		var label = labelMap[locationId];
		if (marker == null || label == null) {
			return;
		}
		marker.visible = true;
		label.visible = true;
		label.text = text;
	}

	function showLabel(locationId:String, text:String):Void {
		var label = labelMap[locationId];
		if (label == null)
			return;
		label.visible = true;
		label.text = text;
	}
}
