package game.shader;

import flixel.system.FlxAssets.FlxShader;

/**
 * Tints the screen based on time of day. `phase` is a normalized value in [0, 1):
 *   0.00 = morning, 0.25 = afternoon, 0.50 = evening, 0.75 = night.
 * Interpolates linearly between the four anchor tints/brightness levels.
 */
class DayNightShader extends FlxShader {
	@:glFragmentSource('
		#pragma header

		uniform float uPhase;

		void main() {
			vec4 base = texture2D(bitmap, openfl_TextureCoordv);

			vec3 morningTint   = vec3(1.00, 0.97, 0.92);
			vec3 afternoonTint = vec3(1.00, 1.00, 1.00);
			vec3 eveningTint   = vec3(1.00, 0.88, 0.78);
			vec3 nightTint     = vec3(0.78, 0.83, 0.95);

			float morningB   = 0.98;
			float afternoonB = 1.00;
			float eveningB   = 0.92;
			float nightB     = 0.78;

			vec3 tint;
			float bright;

			if (uPhase < 0.25) {
				float t = uPhase / 0.25;
				tint   = mix(morningTint, afternoonTint, t);
				bright = mix(morningB,   afternoonB,   t);
			} else if (uPhase < 0.5) {
				float t = (uPhase - 0.25) / 0.25;
				tint   = mix(afternoonTint, eveningTint, t);
				bright = mix(afternoonB,   eveningB,   t);
			} else if (uPhase < 0.75) {
				float t = (uPhase - 0.5) / 0.25;
				tint   = mix(eveningTint, nightTint, t);
				bright = mix(eveningB,   nightB,   t);
			} else {
				float t = (uPhase - 0.75) / 0.25;
				tint   = mix(nightTint, morningTint, t);
				bright = mix(nightB,   morningB,   t);
			}

			gl_FragColor = vec4(base.rgb * tint * bright, base.a);
		}
	')
	public function new() {
		super();
		setPhase(0.0);
	}

	public function setPhase(value:Float):Void {
		uPhase.value = [value];
	}
}
