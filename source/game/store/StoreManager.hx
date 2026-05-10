package game.store;

import flixel.FlxSprite;
import openfl.Assets;

class StoreManager {
	var itemArray:Array<StoreItem>;
	var itemMap:Map<String, StoreItem> = [];
	var overlays:Map<String, FlxSprite> = [];
	var purchased:Map<String, Bool> = [];

	public var isOpen(default, null):Bool = false;
	public var coins:Int = 0;

	public function new() {
		itemArray = haxe.Json.parse(Assets.getText(AssetPaths.store__json));
		for (item in itemArray) {
			itemMap.set(item.id, item);
			if (item.overlay != null) {
				overlays.set(item.id, new FlxSprite(0, 0, item.overlay));
			}
		}
	}

	public function getItems():Array<StoreItem> {
		return itemArray;
	}

	public function getItemById(id:String):Null<StoreItem> {
		return itemMap.get(id);
	}

	public function getOverlay(id:String):Null<FlxSprite> {
		return overlays.get(id);
	}

	public function isPurchased(id:String):Bool {
		return purchased.exists(id);
	}

	public function setOpen(value:Bool):Void {
		isOpen = value;
	}

	public function addCoins(amount:Int):Void {
		coins += amount;
	}

	public function purchase(id:String):Null<StoreItem> {
		var item = itemMap.get(id);
		if (item != null && !isPurchased(id) && coins >= item.price) {
			purchased.set(id, true);
			coins -= item.price;
			return item;
		}
		return null;
	}

	public function getAllPurchased():Array<String> {
		return [for (id in purchased.keys()) id];
	}
}
