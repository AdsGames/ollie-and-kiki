package game.economy;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import game.Fonts;
import game.store.StoreManager;

class CurrencyRenderer extends FlxGroup {
	static final Y = 4;

	var coinsText:FlxBitmapText;
	var storeManager:StoreManager;

	public function new(storeManager:StoreManager) {
		super();
		this.storeManager = storeManager;
		coinsText = new FlxBitmapText(Fonts.glasstownBold);
		coinsText.y = Y;
		coinsText.alignment = RIGHT;
		coinsText.color = FlxColor.YELLOW;
		coinsText.scrollFactor.set(0, 0);
		coinsText.text = "Coins: 0";
		add(coinsText);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		coinsText.text = 'Coins: ${storeManager.coins}';
		coinsText.x = FlxG.width - (coinsText.width + 4);
	}
}
