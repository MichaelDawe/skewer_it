shader_type spatial;
render_mode unshaded;

uniform sampler2D textureImage : source_color;
uniform float pozition;

void fragment() {
	ALBEDO = texture(textureImage, UV).rgb;
	ALBEDO *= max(NORMAL.z, 0.4);
	
	if(pozition > 64.0) {
		ALBEDO += vec3(0.0, 0.25, 0.8) * ((1.0 - NORMAL.z) * ((pozition - 64.0) / 32.0));
		
		if(pozition > 108.0) {
			vec2 uv = SCREEN_UV * (1.0 - SCREEN_UV.yx); //vec2(1.0)- uv.yx; -> 1.-u.yx; Thanks FabriceNeyret !
	    	float vig = uv.x*uv.y * 10.0; //multiply with sth for intensity
	    	vig = pow(vig, 0.5) + 0.5; //change pow for modifying the extend of the  vignette
			ALBEDO = mix(vec3(0.0, 0.2, 0.6) * vig, ALBEDO, 1.0 - ((pozition - 108.0) / 10.0));
		}
	}
}