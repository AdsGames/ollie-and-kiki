package game.store;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import game.Fonts;
import game.Palette;
import game.event.EventBus;

class CurrencyRenderer extends FlxGroup {
	private static final Y:Int = 4;

	// Displayed count moves toward the real count at this many coins per second (minimum).
	private static final ROLL_MIN_RATE:Float = 20.0;

	// Roll always finishes within roughly this many seconds.
	private static final ROLL_MAX_TIME:Float = 0.8;

	private static final POP_SCALE:Float = 1.4;
	private static final FLOAT_DISTANCE:Float = 10.0;
	private static final FLOAT_DURATION:Float = 0.9;

	private var coinsText:FlxBitmapText;
	private var storeManager:StoreManager;

	// Coin count currently shown. Rolls toward storeManager.coins.
	private var displayed:Float;
	private var rollRate:Float;

	public function new(storeManager:StoreManager, events:EventBus) {
		super();
		this.storeManager = storeManager;
		this.displayed = storeManager.coins;
		this.rollRate = ROLL_MIN_RATE;

		coinsText = new FlxBitmapText(Fonts.glasstownBold);
		coinsText.y = Y;
		coinsText.alignment = RIGHT;
		coinsText.color = Palette.YELLOW;
		coinsText.scrollFactor.set(0, 0);
		add(coinsText);
		refreshText();

		events.on("CoinsChanged", function(event) switch (event) {
			case CoinsChanged(delta, _):
				onCoinsChanged(delta);
			default:
		});
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		var target = storeManager.coins;
		if (displayed != target) {
			var step = rollRate * elapsed;
			if (Math.abs(target - displayed) <= step) {
				displayed = target;
			} else {
				displayed += target > displayed ? step : -step;
			}
		}
		refreshText();
	}

	private function refreshText():Void {
		coinsText.text = 'Coins: ${Math.round(displayed)}';
		coinsText.x = FlxG.width - (coinsText.width + 4);
	}

	private function onCoinsChanged(delta:Int):Void {
		rollRate = Math.max(ROLL_MIN_RATE, Math.abs(storeManager.coins - displayed) / ROLL_MAX_TIME);

		// Pop the counter
		FlxTween.cancelTweensOf(coinsText.scale);
		coinsText.scale.set(POP_SCALE, POP_SCALE);
		FlxTween.tween(coinsText.scale, {x: 1.0, y: 1.0}, 0.3, {ease: FlxEase.backOut});

		spawnFloater(delta);
	}

	// "+N" / "-N" that drifts up into the counter and fades out.
	private function spawnFloater(delta:Int):Void {
		var floater = new FlxBitmapText(Fonts.glasstownBold);
		floater.text = delta > 0 ? '+${delta}' : '${delta}';
		floater.color = delta > 0 ? Palette.GREEN : Palette.RED;
		floater.scrollFactor.set(0, 0);
		floater.x = FlxG.width - (floater.width + 4);
		floater.y = Y + FLOAT_DISTANCE + 2;
		add(floater);

		FlxTween.tween(floater, {y: floater.y - FLOAT_DISTANCE, alpha: 0}, FLOAT_DURATION, {
			ease: FlxEase.quadOut,
			onComplete: function(_) {
				remove(floater, true);
				floater.destroy();
			},
		});
	}
}
