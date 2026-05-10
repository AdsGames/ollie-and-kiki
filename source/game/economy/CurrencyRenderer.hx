package game.economy;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import game.Fonts;
import game.Palette;
import game.store.StoreManager;

class CurrencyRenderer extends FlxGroup {
	private static final Y:Int = 4;

	private var coinsText:FlxBitmapText;
	private var storeManager:StoreManager;

	public function new(storeManager:StoreManager) {
		super();
		this.storeManager = storeManager;
		coinsText = new FlxBitmapText(Fonts.glasstownBold);
		coinsText.y = Y;
		coinsText.alignment = RIGHT;
		coinsText.color = Palette.YELLOW;
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
