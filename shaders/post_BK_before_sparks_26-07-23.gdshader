// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// By Michael Dawe, partially based on:
// The Universe Within - by Martijn Steinrucken aka BigWings 2018
// Email:countfrolic@gmail.com Twitter:@The_ArtOfCode
// License under Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float catch;
uniform float damaged;
uniform float sparks;
uniform float highscore;

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	vec3 col = texture(screen_texture, SCREEN_UV).rgb;
	
	vec2 uv = SCREEN_UV * (1.0 - SCREEN_UV.yx); //vec2(1.0)- uv.yx; -> 1.-u.yx; Thanks FabriceNeyret !
	float vig = 1.0 - (uv.x*uv.y * 16.0); //multiply with sth for intensity
	vig = pow(vig, 0.5);
	
	col *= 1.0 + (catch * vig);
	col *= 1.0 + (vec3(1.0, 0.8, 0.4) * highscore * vig);
	col = mix(col, (col * vec3(1.0, 0.0, 0.0)) + vec3(0.4, 0.0, 0.0), vig * damaged);
	
	col += ((1.0 - UV.y) * sparks * vec3(1.0, 0.4, 0.05));
	
	ALBEDO = col;
}