shader_type spatial;
render_mode unshaded;

uniform float catch;
uniform float damaged;
uniform float sparks;
uniform float highscore;

uniform sampler2D textureImage : source_color;

void fragment() {
	vec3 col = texture(textureImage, UV).rgb;
	col *= abs((NORMAL.x + NORMAL.y) / 2.0 - 1.0) * 0.7;
	
	vec2 uv = SCREEN_UV * (1.0 - SCREEN_UV.yx); //vec2(1.0)- uv.yx; -> 1.-u.yx; Thanks FabriceNeyret !
	float vig = 1.0 - (uv.x*uv.y * 16.0); //multiply with sth for intensity
	vig = pow(vig, 0.5);
	
	col *= 1.0 + (catch * vig);
	col *= 1.0 + (vec3(1.0, 0.8, 0.4) * highscore * vig);
	col = mix(col, (col * vec3(1.0, 0.0, 0.0)) + vec3(0.4, 0.0, 0.0), vig * damaged);
	
	col += SCREEN_UV.y * sparks * vec3(1.0, 0.4, 0.05);
	
	ALBEDO = clamp(col, 0.0, 1.0);
}