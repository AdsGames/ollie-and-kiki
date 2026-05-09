package game.task;

enum TaskState {
	Idle; // task exists but player hasn't accepted it yet
	Accepted; // player accepted
	PickedUp; // item in hand
	Delivered; // done
}
