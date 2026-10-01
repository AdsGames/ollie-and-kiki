package game.store;

typedef StoreItem = {
	id:String,
	name:String,
	dialogue:String,
	image:String,
	price:Int,
	overlay:Null<String>,
	// Gameplay effects, additive when the item is owned. All optional.
	?speedBonus:Float,
	?carryBonus:Int,
	?unlocks:Array<String>,
}
