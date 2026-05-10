package game.ui;

import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * Renders a 9-slice panel from the shared dialogue spritesheet.
 * The sheet is a 3x3 grid of 16x16 tiles (corners, edges, centre).
 * Minimum usable size is TILE*2 in each dimension.
 */
class NineSlice extends FlxGroup {
	// The size of each tile in the source spritesheet.
	public static inline final TILE:Int = 16;

	public function new(x:Float, y:Float, w:Int, h:Int) {
		super();

		var iw = w - TILE * 2;
		var ih = h - TILE * 2;
		var mx = x + TILE;
		var my = y + TILE;
		var rx = x + w - TILE;
		var by = y + h - TILE;

		slice(0, x, y, TILE, TILE);
		slice(1, mx, y, iw, TILE);
		slice(2, rx, y, TILE, TILE);
		slice(3, x, my, TILE, ih);
		slice(4, mx, my, iw, ih);
		slice(5, rx, my, TILE, ih);
		slice(6, x, by, TILE, TILE);
		slice(7, mx, by, iw, TILE);
		slice(8, rx, by, TILE, TILE);
	}

	private function slice(frame:Int, x:Float, y:Float, w:Float, h:Float):Void {
		var s = new FlxSprite(x, y);
		s.loadGraphic(AssetPaths.dialogue__png, true, TILE, TILE);
		s.animation.frameIndex = frame;
		s.setGraphicSize(Std.int(w), Std.int(h));
		s.updateHitbox();
		s.scrollFactor.set(0, 0);
		add(s);
	}
}
