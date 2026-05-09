package game.economy;

import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import game.Fonts;

/** HUD line showing the player's current coin balance. */
class CurrencyRenderer extends FlxGroup {
	static final Y = 60;

	var coinsText:FlxBitmapText;

	public function new() {
		super();
		coinsText = new FlxBitmapText(Fonts.glasstown);
		coinsText.x = 8;
		coinsText.y = Y;
		coinsText.fieldWidth = 100;
		coinsText.multiLine = false;
		coinsText.color = FlxColor.YELLOW;
		coinsText.scrollFactor.set(0, 0);
		coinsText.text = "Coins: 0";
		add(coinsText);
	}

	public function updateCoins(coins:Int):Void {
		coinsText.text = 'Coins: $coins';
	}
}
