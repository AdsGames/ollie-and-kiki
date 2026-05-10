package game.location;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import game.Fonts;
import game.Palette;

class LocationMarker extends FlxGroup {
	public var location:Location;

	var sprite:FlxSprite;
	var label:FlxBitmapText;

	public function new(location:Location) {
		super();
		this.location = location;

		sprite = new FlxSprite(location.x, location.y, AssetPaths.marker__png);
		sprite.x -= sprite.width / 2;
		sprite.scrollFactor.set(1, 1);
		add(sprite);

		label = new FlxBitmapText(Fonts.glasstownBold);
		label.x = sprite.x;
		label.autoSize = true;
		label.multiLine = true;
		label.alignment = CENTER;
		label.color = Palette.WHITE;
		label.scrollFactor.set(1, 1);
		add(label);

		visible = false;
	}

	public function show(text:String):Void {
		visible = true;
		label.text = text;
	}

	public function hide():Void {
		visible = false;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		var animTime = FlxG.game.ticks / 100;
		sprite.y = location.y - (sprite.height + 8) + 2 * Math.sin(animTime);
		label.x = location.x - label.width / 2;
		label.y = sprite.y - label.height - 2;
	}
}
