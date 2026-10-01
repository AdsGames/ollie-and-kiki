package game.event;

import game.store.StoreItem;
import game.task.Task;

enum GameEvent {
	TaskAccepted(task:Task);
	TaskPickedUp(task:Task);
	TaskDelivered(task:Task);
	TaskExpired(task:Task);
	TaskTimerWarned(task:Task);
	DialogueStarted;
	DialogueEnded;
	StoreOpened;
	StoreClosed;
	CoinsChanged(delta:Int, total:Int);
	ItemPurchased(item:StoreItem);
	DayEnded(day:Int);
	DaySummaryClosed;
}
