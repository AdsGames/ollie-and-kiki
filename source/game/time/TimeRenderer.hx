package game.time;

import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import game.Fonts;
import game.Palette;

class TimeRenderer extends FlxGroup {
	private static final X:Int = 4;
	private static final Y:Int = 4;

	private var timeText:FlxBitmapText;
	private var timeController:TimeController;

	public function new(timeController:TimeController) {
		super();
		this.timeController = timeController;
		timeText = new FlxBitmapText(Fonts.glasstownBold);
		timeText.x = X;
		timeText.y = Y;
		timeText.color = Palette.YELLOW;
		timeText.scrollFactor.set(0, 0);
		timeText.text = timeController.getTimeString();
		add(timeText);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		timeText.text = timeController.getTimeString();
	}
}
