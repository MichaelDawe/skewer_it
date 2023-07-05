shader_type spatial;
render_mode unshaded;

uniform sampler2D textureImage : source_color;

void fragment() {
	ALBEDO = texture(textureImage, UV).rgb * (((NORMAL.x + NORMAL.y) / 2.0) - 1.0);
}