// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// By Michael Dawe, partially based on:
// The Universe Within - by Martijn Steinrucken aka BigWings 2018
// Email:countfrolic@gmail.com Twitter:@The_ArtOfCode
// License under Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

shader_type spatial;
render_mode unshaded;

uniform float catch;
uniform float damaged;
uniform float sparks;
uniform float highscore;

uniform vec3 background;
uniform float t;

float random(vec2 par){
   return fract(sin(dot(par.xy,vec2(12.9898,78.233))) * 43758.5453);
}

vec2 random2(vec2 par){
	float rand = random(par);
	return vec2(rand, random(par+rand));
}

void fragment() {
    float layers = 6.0;
    float scale = 25.0;
	
	float stars;
    float depth;
    vec2 index;
	vec2 uv;
    vec2 seed;
    vec2 local_uv;
    vec2 pos;
    float phase;
	
	for(float i = 0.0; i < layers; i++)
	{
        depth = fract(i/layers + t);
        
        //Get uv from the fragment coordinates and depth
    	uv.x = 0.5 - UV.x;
    	uv.y = 0.5 - UV.y;
    	uv *= mix(scale, 0.0, depth);
        
        //The local cell
        index = floor(uv);
        
        //Local cell seed;
        seed = 20.0 * i + index;
        
        //The local cell coordinates
        local_uv = fract(i + uv) - 0.5;
        
        //Get a random position for the local cell
        pos = 0.8 * (random2(seed) - 0.5);
        
        //Get a random phase
        phase = 128.0 * random(seed);
        
		//Get distance to the generated point, add fading to distant points
		//Add the distance to the sum
		stars += pow(abs(1.0 - length(local_uv - pos)), 80.0 + 20.0 * sin(phase + 8.0 * TIME)) * min(1.0, depth * 2.0);
	}
	
	uv = SCREEN_UV * (1.0 - SCREEN_UV.yx); //vec2(1.0)- uv.yx; -> 1.-u.yx; Thanks FabriceNeyret !
	float vig = uv.x*uv.y * 10.0; //multiply with sth for intensity
	vig = pow(vig, 0.5) + 0.5; //change pow for modifying the extend of the  vignette
	
	vec3 backgroundViged = background * vig;
	
	vec3 col = (vec3(stars) * (1.0 - backgroundViged)) + backgroundViged;
	
	uv = SCREEN_UV * (1.0 - SCREEN_UV.yx); //vec2(1.0)- uv.yx; -> 1.-u.yx; Thanks FabriceNeyret !
	vig = 1.0 - (uv.x*uv.y * 16.0); //multiply with sth for intensity
	vig = pow(vig, 0.5);
	
	col *= 1.0 + (catch * vig);
	col *= 1.0 + (vec3(1.0, 0.8, 0.4) * highscore * vig);
	col = mix(col, (col * vec3(1.0, 0.0, 0.0)) + vec3(0.4, 0.0, 0.0), vig * damaged);
	
	col += ((1.0 - UV.y) * sparks * vec3(1.0, 0.4, 0.05));
	
	ALBEDO = col;
}
