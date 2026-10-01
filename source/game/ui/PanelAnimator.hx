package game.ui;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

/**
 * Slides a HUD panel (a FlxGroup of screen-space sprites) in and out vertically.
 * Members keep their layout positions; the animator shifts them by a shared offset.
 */
class PanelAnimator {
	private static final SHOW_DURATION:Float = 0.2;
	private static final HIDE_DURATION:Float = 0.12;

	// Current vertical shift applied to every member.
	public var offset(default, null):Float;

	// True while the panel is shown or sliding in.
	public var isShown(default, null):Bool;

	private var group:FlxGroup;
	private var hiddenOffset:Float;
	private var tween:Null<FlxTween>;

	/**
	 * @param group Panel to animate.
	 * @param hiddenOffset Vertical shift when hidden. Negative slides up off screen, positive slides down.
	 */
	public function new(group:FlxGroup, hiddenOffset:Float) {
		this.group = group;
		this.hiddenOffset = hiddenOffset;
		this.offset = 0;
		this.isShown = false;
		this.tween = null;
	}

	public function show():Void {
		if (isShown) {
			return;
		}
		isShown = true;
		cancel();
		if (!group.visible) {
			setOffset(hiddenOffset);
		}
		group.visible = true;
		tween = FlxTween.num(offset, 0, SHOW_DURATION, {ease: FlxEase.backOut}, setOffset);
	}

	public function hide():Void {
		if (!isShown) {
			return;
		}
		isShown = false;
		cancel();
		tween = FlxTween.num(offset, hiddenOffset, HIDE_DURATION, {
			ease: FlxEase.quadIn,
			onComplete: function(_) group.visible = false,
		}, setOffset);
	}

	public function toggle():Void {
		if (isShown) {
			hide();
		} else {
			show();
		}
	}

	private function cancel():Void {
		if (tween != null) {
			tween.cancel();
			tween = null;
		}
	}

	private function setOffset(value:Float):Void {
		var delta = Math.round(value) - Math.round(offset);
		offset = value;
		if (delta != 0) {
			shift(group, delta);
		}
	}

	private static function shift(basic:FlxBasic, delta:Float):Void {
		if (Std.isOfType(basic, FlxObject)) {
			var obj:FlxObject = cast basic;
			obj.y = obj.y + delta;
		} else if (Std.isOfType(basic, FlxTypedGroup)) {
			var g:FlxTypedGroup<FlxBasic> = cast basic;
			for (member in g.members) {
				if (member != null) {
					shift(member, delta);
				}
			}
		}
	}
}
