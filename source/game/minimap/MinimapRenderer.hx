package game.minimap;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import game.Palette;
import game.location.LocationManager;

class MinimapRenderer extends FlxGroup {
	static final X = 172;
	static final Y = 4;
	static final W = 64;
	static final H = 64;
	static final DOT = 2;

	var worldW:Int;
	var worldH:Int;
	var playerDot:FlxSprite;

	public function new(worldW:Int, worldH:Int, locationManager:LocationManager) {
		super();
		this.worldW = worldW;
		this.worldH = worldH;

		var bg = new FlxSprite(X, Y);
		bg.makeGraphic(W, H, Palette.BLACK);
		bg.scrollFactor.set(0, 0);
		add(bg);

		var scaleX = W / (worldW * 8.0);
		var scaleY = H / (worldH * 8.0);
		for (loc in locationManager.getAllLocations()) {
			var dot = new FlxSprite(X + loc.x * scaleX - DOT * 0.5, Y + loc.y * scaleY - DOT * 0.5);
			dot.makeGraphic(DOT, DOT, Palette.WHITE);
			dot.scrollFactor.set(0, 0);
			add(dot);
		}

		playerDot = new FlxSprite(X + W * 0.5, Y + H * 0.5);
		playerDot.makeGraphic(DOT, DOT, Palette.YELLOW);
		playerDot.scrollFactor.set(0, 0);
		add(playerDot);

		visible = false;
	}

	public function updatePlayerPos(px:Float, py:Float):Void {
		var scaleX = W / (worldW * 8.0);
		var scaleY = H / (worldH * 8.0);
		playerDot.x = X + px * scaleX - DOT * 0.5;
		playerDot.y = Y + py * scaleY - DOT * 0.5;
	}

	public function toggle():Void {
		visible = !visible;
	}
}
