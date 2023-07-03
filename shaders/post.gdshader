shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	vec3 col = texture(screen_texture, SCREEN_UV).rgb;
	col = vec3(col.g, col.b, col.r);
	ALBEDO = col;
}