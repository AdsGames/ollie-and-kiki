package;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepadInputID;

enum abstract Action(Int) {
	// Move up action.
	var MoveUp;
	// Move down action.
	var MoveDown;
	// Move left action.
	var MoveLeft;
	// Move right action.
	var MoveRight;
	// Interact / confirm action.
	var Interact;
	// Cancel / back action.
	var Cancel;
	// Open quest log action.
	var QuestLog;
	// Open minimap action.
	var Minimap;
	// Snap a photo for photo-type tasks.
	var Photo;
	// Open the pause menu.
	var Pause;
	// Any input action.
	var Any;
}

class InputManager {
	private static final DEADZONE:Float = 0.3;

	// Hint tokens in text (e.g. "press {QuestLog}") are replaced with the button label.
	private static final HINT_TOKEN:EReg = ~/\{(\w+)\}/g;

	// True when the last input came from a gamepad. Drives on-screen button labels.
	public static var usingGamepad(default, null):Bool = false;

	// Left stick axes at the end of the previous frame, so justPressed fires only when the stick crosses the deadzone.
	private static var prevStickX:Float = 0;
	private static var prevStickY:Float = 0;

	/**
	 * Record stick axes for next frame's edge detection. Hooked to FlxG.signals.postUpdate by InitState.
	 */
	public static function latchStick():Void {
		var gamepad = FlxG.gamepads.firstActive;
		prevStickX = gamepad != null ? gamepad.getXAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) : 0;
		prevStickY = gamepad != null ? gamepad.getYAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) : 0;
	}

	/**
	 * Track the last used device. Hooked to FlxG.signals.preUpdate by InitState.
	 */
	public static function poll():Void {
		if (FlxG.keys.justPressed.ANY) {
			usingGamepad = false;
			return;
		}
		var gamepad = FlxG.gamepads.firstActive;
		if (gamepad != null && gamepad.justPressed.ANY) {
			usingGamepad = true;
		}
	}

	/**
	 * Button label for an action on the current device.
	 */
	public static function label(action:Action):String {
		if (usingGamepad) {
			return switch (action) {
				case Interact: "A";
				case Cancel: "B";
				case QuestLog: "Y";
				case Minimap: "SELECT";
				case Photo: "X";
				case Pause: "START";
				default: "?";
			}
		}
		return switch (action) {
			case Interact: "E";
			case Cancel: "ESC";
			case QuestLog: "Q";
			case Minimap: "M";
			case Photo: "F";
			case Pause: "ESC";
			default: "?";
		}
	}

	/**
	 * Replace hint tokens such as {QuestLog} with the label for the current device.
	 */
	public static function formatHints(text:String):String {
		return HINT_TOKEN.map(text, function(re) {
			return switch (re.matched(1)) {
				case "Interact": label(Interact);
				case "Cancel": label(Cancel);
				case "QuestLog": label(QuestLog);
				case "Minimap": label(Minimap);
				case "Photo": label(Photo);
				case "Pause": label(Pause);
				default: re.matched(0);
			}
		});
	}

	public static function pressed(action:Action):Bool {
		var gamepad = FlxG.gamepads.firstActive;
		return switch (action) {
			case MoveUp: FlxG.keys.pressed.UP || FlxG.keys.pressed.W || (gamepad != null
					&& (gamepad.pressed.DPAD_UP || gamepad.getYAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) < -DEADZONE));
			case MoveDown: FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S || (gamepad != null
					&& (gamepad.pressed.DPAD_DOWN || gamepad.getYAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) > DEADZONE));
			case MoveLeft: FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A || (gamepad != null
					&& (gamepad.pressed.DPAD_LEFT || gamepad.getXAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) < -DEADZONE));
			case MoveRight: FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D || (gamepad != null
					&& (gamepad.pressed.DPAD_RIGHT || gamepad.getXAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) > DEADZONE));
			default: false;
		}
	}

	public static function justPressed(action:Action):Bool {
		var gamepad = FlxG.gamepads.firstActive;
		return switch (action) {
			case MoveUp: FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W || (gamepad != null
					&& (gamepad.justPressed.DPAD_UP
						|| (gamepad.getYAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) < -DEADZONE && prevStickY >= -DEADZONE)));
			case MoveDown: FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S || (gamepad != null
					&& (gamepad.justPressed.DPAD_DOWN
						|| (gamepad.getYAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) > DEADZONE && prevStickY <= DEADZONE)));
			case MoveLeft: FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A || (gamepad != null
					&& (gamepad.justPressed.DPAD_LEFT
						|| (gamepad.getXAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) < -DEADZONE && prevStickX >= -DEADZONE)));
			case MoveRight: FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D || (gamepad != null
					&& (gamepad.justPressed.DPAD_RIGHT
						|| (gamepad.getXAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) > DEADZONE && prevStickX <= DEADZONE)));
			case Interact:
				FlxG.keys.justPressed.Z
				|| FlxG.keys.justPressed.E
				|| FlxG.keys.justPressed.ENTER
				|| FlxG.keys.justPressed.SPACE
				|| (gamepad != null && gamepad.justPressed.A);
			case Cancel: FlxG.keys.justPressed.ESCAPE || (gamepad != null && gamepad.justPressed.B);
			case QuestLog: FlxG.keys.justPressed.Q || (gamepad != null && gamepad.justPressed.Y);
			case Minimap: FlxG.keys.justPressed.M || (gamepad != null && gamepad.justPressed.BACK);
			case Photo: FlxG.keys.justPressed.F || (gamepad != null && gamepad.justPressed.X);
			case Pause: FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.P || (gamepad != null && gamepad.justPressed.START);
			case Any: FlxG.keys.justPressed.ANY || (gamepad != null
					&& (gamepad.justPressed.A || gamepad.justPressed.START || gamepad.justPressed.B || gamepad.justPressed.X || gamepad.justPressed.Y));
		}
	}
}
