shader_type spatial;
render_mode unshaded;

uniform sampler2D textureImage : source_color;

void fragment() {
	vec3 col = texture(textureImage, UV).rgb;
	if(col == vec3(1.0, 0.0, 1.0)) {
		col = vec3(1.0);
	}
	ALBEDO = texture(textureImage, UV).rgb;
}