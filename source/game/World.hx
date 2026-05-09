package game;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxState;
import game.WorldMap;

class World {
	public var map:WorldMap;
	public var player:Player;

	public function new(state:FlxState) {
		map = new WorldMap(state);

		player = new Player(100, 100);
		state.add(player);

		// Camera follow
		FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 1.0);
		// FlxG.camera.setScrollBounds(0, 0, map.mapWidth * 8, map.mapHeight * 8);
	}
}
