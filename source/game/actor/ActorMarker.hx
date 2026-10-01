package game.actor;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import game.Fonts;
import game.Palette;
import game.location.Location;

class ActorMarker extends FlxGroup {
	private static final LABEL_WIDTH:Int = 8;

	// The actor represented by this marker.
	public var actor:Actor;

	// The location this marker is anchored to.
	public var location:Location;

	private var sprite:FlxSprite;

	// Exclamation-mark label shown when the actor has an available quest.
	public var questLabel:FlxBitmapText;

	public function new(actor:Actor, location:Location) {
		super();
		this.actor = actor;
		this.location = location;

		sprite = new FlxSprite(actor.x, actor.y);
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
	}

	/**
	 * Show or hide the "!" label. Pops in when it first appears.
	 */
	public function setQuest(available:Bool):Void {
		if (available && sprite.visible && !questLabel.visible) {
			FlxTween.cancelTweensOf(questLabel.scale);
			questLabel.scale.set(0.2, 0.2);
			FlxTween.tween(questLabel.scale, {x: 1.0, y: 1.0}, 0.35, {ease: FlxEase.elasticOut});
		}
		questLabel.visible = available && sprite.visible;
	}

	public function setVisible(visible:Bool):Void {
		sprite.visible = visible;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		// Track the actor's live world position so mobile actors stay in sync.
		sprite.x = actor.x;
		sprite.y = actor.y;
		// Quantize the bob to whole pixels so the "!" stays on the pixel grid.
		var bob = Math.round(2 * Math.sin(FlxG.game.ticks / 100));
		questLabel.x = Math.floor(sprite.x + sprite.width / 2 - LABEL_WIDTH / 2);
		questLabel.y = Math.floor(sprite.y - questLabel.height - 2 + bob);
	}
}
