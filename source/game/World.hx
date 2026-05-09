package game;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxState;
import game.WorldMap;
import game.dialogue.DialogueLine;
import game.dialogue.DialogueManager;

class World {
	public var map:WorldMap;
	public var player:Player;
	public var dialogueManager:DialogueManager;

	public function new(state:FlxState) {
		map = new WorldMap(state);

		dialogueManager = new DialogueManager(state);

		player = new Player(100, 100, dialogueManager);
		state.add(player);

		// Camera follow
		FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 1.0);
		// FlxG.camera.setScrollBounds(0, 0, map.mapWidth * 8, map.mapHeight * 8);
	}

	public function update(elapsed:Float):Void {
		dialogueManager.update(elapsed);
	}
}
