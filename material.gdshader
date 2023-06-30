shader_type spatial;
render_mode unshaded;

uniform sampler2D textureImage : source_color;
uniform float pozition;

void fragment() {
	ALBEDO = texture(textureImage, UV).rgb;
	ALBEDO *= max(NORMAL.z, 0.3);
	if(pozition > 128.0) {
		ALBEDO += vec3(0.6, 0.0, 0.4);
	}
}
