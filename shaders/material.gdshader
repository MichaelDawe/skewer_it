shader_type spatial;
render_mode unshaded;

uniform sampler2D textureImage : source_color;
uniform float pozition;
uniform bool displayCatchOverlay = true;

void fragment() {
	ALBEDO = texture(textureImage, UV).rgb;
	ALBEDO *= max(NORMAL.z, 0.4);
	if(displayCatchOverlay) {
		if(pozition > 64.0) {
			ALBEDO += vec3(0.0, 0.3, 0.8) * ((1.0 - NORMAL.z) * ((pozition - 64.0) / 32.0));
		}
	}
}
