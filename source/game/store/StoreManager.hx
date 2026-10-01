package game.store;

import flixel.FlxSprite;
import game.dialogue.DialogueLine;
import game.dialogue.DialogueManager;
import game.event.EventBus;
import openfl.Assets;

class StoreManager {
	private var dialogueManager:DialogueManager;
	private var events:EventBus;
	private var itemArray:Array<StoreItem>;
	private var itemMap:Map<String, StoreItem>;
	private var overlays:Map<String, FlxSprite>;
	private var purchased:Map<String, Bool>;

	// Whether currently opened
	public var isOpen(default, null):Bool = false;

	// Player's current coin count
	public var coins:Int;

	public function new(dialogueManager:DialogueManager, events:EventBus) {
		this.itemMap = [];
		this.overlays = [];
		this.purchased = [];
		this.coins = 0;
		this.dialogueManager = dialogueManager;
		this.events = events;

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
		if (isOpen == value) {
			return;
		}
		isOpen = value;
		events.emit(value ? StoreOpened : StoreClosed);
	}

	public function addCoins(amount:Int):Void {
		if (amount == 0) {
			return;
		}
		coins += amount;
		events.emit(CoinsChanged(amount, coins));
	}

	public function purchase(id:String):Null<StoreItem> {
		var item = itemMap.get(id);
		if (item != null && !isPurchased(id) && coins >= item.price) {
			purchased.set(id, true);
			addCoins(-item.price);
			events.emit(ItemPurchased(item));
			// Close the store BEFORE starting dialogue so state-stack ordering is
			// StoreClosed -> DialogueStarted (otherwise the pop would try to pop
			// the Dialogue state that was just pushed on top of Store).
			setOpen(false);
			dialogueManager.startDialogue([new DialogueLine("kiki", item.dialogue)]);
			return item;
		}
		return null;
	}

	public function getAllPurchased():Array<String> {
		return [for (id in purchased.keys()) id];
	}
}
