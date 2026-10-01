package game.task;

enum TaskType {
	Delivery; // carry an item from `from` to one of `tos`
	Find; // walk to one of `tos` and trigger dialogue
	Photo; // be near `targetActorId` with state/time match, press Photo key
	Escort; // an actor follows you from `from` to one of `tos`
}
