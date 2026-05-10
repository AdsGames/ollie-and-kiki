package game.minimap;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import game.Palette;
import game.location.LocationManager;
import game.ui.NineSlice;

class MinimapRenderer extends FlxGroup {
	private static final X:Int = 172;
	private static final Y:Int = 4;
	private static final W:Int = 64;
	private static final H:Int = 64;
	private static final DOT:Int = 2;

	// Content area sits inside the NineSlice border
	private static final IX:Int = X + NineSlice.TILE;
	private static final IY:Int = Y + NineSlice.TILE;
	private static final IW:Int = W - NineSlice.TILE * 2;
	private static final IH:Int = H - NineSlice.TILE * 2;

	// World dimensions for scaling the minimap dots
	private var worldW:Int;
	private var worldH:Int;
	private var playerDot:FlxSprite;

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
