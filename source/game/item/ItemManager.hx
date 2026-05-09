package game.item;

import flixel.graphics.FlxGraphic;
import game.item.Item;
import openfl.Assets;

class ItemManager {
	public var items:Map<String, Item>;

	public function new() {
		items = new Map();
	}

	/**
	 * Loads items from a JSON file and populates the items map.
	 */
	public function loadItems():Void {
		var raw = Assets.getText(AssetPaths.items__json);
		var data:Array<{
			var id:String;
			var name:String;
			var description:String;
			var value:Int;
			var image:String;
		}> = haxe.Json.parse(raw);

		for (entry in data) {
			var item = new Item();

			// Check image
			var img = FlxGraphic.fromBitmapData(Assets.getBitmapData(entry.image), false);
			if (img == null) {
				trace('Skipping item "${entry.id}": missing image "${entry.image}".');
				continue;
			}

			img.persist = true;

			item.id = entry.id;
			item.name = entry.name;
			item.description = entry.description;
			item.value = entry.value;
			item.image = img;
			items.set(item.id, item);

			trace('Loaded item: ' + item.name);
		}
	}

	/**
	 * Retrieves an item by its ID.
	 * @param id The ID of the item to retrieve.
	 * @return The item with the specified ID, or null if not found.
	 */
	public function getItemById(id:String):Null<Item> {
		var item = items.get(id);
		if (item == null) {
			trace("Warning: Item with ID '" + id + "' not found.");
		}
		return item;
	}
}
