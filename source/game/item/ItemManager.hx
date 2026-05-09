package game.item;

import game.item.Item;
import openfl.Assets;

class ItemManager {
	public var items:Array<Item>;

	public function new() {
		items = [];
	}

	/**
	 * Loads items from a JSON file and populates the items array.
	 */
	public function loadItems():Void {
		var raw = Assets.getText(AssetPaths.items__json);
		var data:Array<{
			var id:String;
			var name:String;
			var description:String;
			var value:Int;
		}> = haxe.Json.parse(raw);

		for (entry in data) {
			var item = new Item();
			item.id = entry.id;
			item.name = entry.name;
			item.description = entry.description;
			item.value = entry.value;
			items.push(item);

			trace('Loaded item: ' + item.name);
		}
	}

	/**
	 * Retrieves an item by its ID.
	 * @param id The ID of the item to retrieve.
	 * @return The item with the specified ID, or null if not found.
	 */
	public function getItemById(id:String):Null<Item> {
		for (item in items) {
			if (item.id == id) {
				return item;
			}
		}
		return null;
	}
}
