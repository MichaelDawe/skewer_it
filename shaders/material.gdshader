shader_type spatial;
render_mode unshaded;

uniform sampler2D textureImage : source_color;
uniform float pozition;

uniform vec3 background;

void fragment() {
	// made shading look better
	NORMAL *= NORMAL;
	
	vec3 col = texture(textureImage, UV).rgb;
	col *= (vec3(0.7, 0.55, 0.25) * NORMAL.z) + vec3(0.35, 0.4, 0.5);
	
	if(pozition > 64.0) {
		col += background * ((1.0 - NORMAL.z) * ((pozition - 64.0) / 32.0));
	}
	ALBEDO = col;
}