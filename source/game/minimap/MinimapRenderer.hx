package game.minimap;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import game.Palette;
import game.location.LocationManager;
import game.ui.NineSlice;

class MinimapRenderer extends FlxGroup {
	static final X = 172;
	static final Y = 4;
	static final W = 64;
	static final H = 64;
	static final DOT = 2;

	// Content area sits inside the NineSlice border
	static final IX = X + NineSlice.TILE;
	static final IY = Y + NineSlice.TILE;
	static final IW = W - NineSlice.TILE * 2;
	static final IH = H - NineSlice.TILE * 2;

	var worldW:Int;
	var worldH:Int;
	var playerDot:FlxSprite;

	public function new(worldW:Int, worldH:Int, locationManager:LocationManager) {
		super();
		this.worldW = worldW;
		this.worldH = worldH;

		add(new NineSlice(X, Y, W, H));

		var scaleX = IW / (worldW * 8.0);
		var scaleY = IH / (worldH * 8.0);
		for (loc in locationManager.getAllLocations()) {
			var dot = new FlxSprite(IX + loc.x * scaleX - DOT * 0.5, IY + loc.y * scaleY - DOT * 0.5);
			dot.makeGraphic(DOT, DOT, Palette.WHITE);
			dot.scrollFactor.set(0, 0);
			add(dot);
		}

		playerDot = new FlxSprite(IX + IW * 0.5, IY + IH * 0.5);
		playerDot.makeGraphic(DOT, DOT, Palette.YELLOW);
		playerDot.scrollFactor.set(0, 0);
		add(playerDot);

		visible = false;
	}

	public function updatePlayerPos(px:Float, py:Float):Void {
		var scaleX = IW / (worldW * 8.0);
		var scaleY = IH / (worldH * 8.0);
		playerDot.x = IX + px * scaleX - DOT * 0.5;
		playerDot.y = IY + py * scaleY - DOT * 0.5;
	}

	public function toggle():Void {
		visible = !visible;
	}
}
