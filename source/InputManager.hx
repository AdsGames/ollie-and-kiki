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
	// Any input action.
	var Any;
}

class InputManager {
	private static final DEADZONE:Float = 0.3;

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
					&& (gamepad.justPressed.DPAD_UP || gamepad.getYAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) < -DEADZONE));
			case MoveDown: FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S || (gamepad != null
					&& (gamepad.justPressed.DPAD_DOWN || gamepad.getYAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) > DEADZONE));
			case MoveLeft: FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A || (gamepad != null
					&& (gamepad.justPressed.DPAD_LEFT || gamepad.getXAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) < -DEADZONE));
			case MoveRight: FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D || (gamepad != null
					&& (gamepad.justPressed.DPAD_RIGHT || gamepad.getXAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) > DEADZONE));
			case Interact:
				FlxG.keys.justPressed.Z
				|| FlxG.keys.justPressed.E
				|| FlxG.keys.justPressed.ENTER
				|| FlxG.keys.justPressed.SPACE
				|| (gamepad != null && gamepad.justPressed.A);
			case Cancel: FlxG.keys.justPressed.ESCAPE || (gamepad != null && gamepad.justPressed.B);
			case QuestLog: FlxG.keys.justPressed.Q || (gamepad != null && gamepad.justPressed.Y);
			case Minimap: FlxG.keys.justPressed.M || (gamepad != null && gamepad.justPressed.START);
			case Any: FlxG.keys.justPressed.ANY || (gamepad != null
					&& (gamepad.justPressed.A || gamepad.justPressed.START || gamepad.justPressed.B || gamepad.justPressed.X || gamepad.justPressed.Y));
		}
	}
}
