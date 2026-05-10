package game.actor;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import game.Fonts;
import game.Palette;
import game.location.Location;

class ActorMarker extends FlxGroup {
	static final LABEL_WIDTH = 8;

	public var actor:Actor;
	public var location:Location;

	var sprite:FlxSprite;
	var questLabel:FlxBitmapText;

	public function new(actor:Actor, location:Location) {
		super();
		this.actor = actor;
		this.location = location;

		sprite = new FlxSprite(location.x, location.y);
		sprite.loadGraphic(actor.image);
		sprite.scrollFactor.set(1, 1);
		add(sprite);

		questLabel = new FlxBitmapText(Fonts.glasstownBold);
		questLabel.fieldWidth = LABEL_WIDTH;
		questLabel.alignment = CENTER;
		questLabel.color = Palette.YELLOW;
		questLabel.text = "!";
		questLabel.visible = false;
		questLabel.scrollFactor.set(1, 1);
		add(questLabel);
	}

	public function showQuest():Void {
		questLabel.visible = true;
	}

	public function hideQuest():Void {
		questLabel.visible = false;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		var bob = 2 * Math.sin(FlxG.game.ticks / 100);
		questLabel.x = sprite.x + sprite.width / 2 - LABEL_WIDTH / 2;
		questLabel.y = sprite.y - questLabel.height - 2 + bob;
	}
}
