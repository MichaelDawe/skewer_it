shader_type spatial;
render_mode unshaded;

uniform float catch;
uniform float damaged;
uniform float sparks;
uniform float highscore;

uniform sampler2D textureImage : source_color;
uniform float pozition;

uniform vec3 background;

void fragment() {
	// made shading look better
	NORMAL *= NORMAL;
	
	vec3 col = texture(textureImage, UV).rgb;
	col *= abs((vec3(0.7, 0.55, 0.25) * NORMAL.z) + vec3(0.35, 0.4, 0.5));
	
	if(pozition > 64.0) {
		col += background * abs((1.0 - NORMAL.z) * ((pozition - 64.0) / 32.0));
	}
	
	vec2 uv = SCREEN_UV * (1.0 - SCREEN_UV.yx); //vec2(1.0)- uv.yx; -> 1.-u.yx; Thanks FabriceNeyret !
	float vig = 1.0 - (uv.x*uv.y * 16.0); //multiply with sth for intensity
	vig = pow(vig, 0.5);
	
	col *= 1.0 + (catch * vig);
	col *= 1.0 + (vec3(1.0, 0.8, 0.4) * highscore * vig);
	col = mix(col, (col * vec3(1.0, 0.0, 0.0)) + vec3(0.4, 0.0, 0.0), vig * damaged);
	
	col += SCREEN_UV.y * sparks * vec3(1.0, 0.4, 0.05);
	
	ALBEDO = col;
}