shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back;

uniform vec4 core_color : source_color = vec4(0.3, 0.6, 1.0, 1.0);
uniform vec4 flash_color : source_color = vec4(0.8, 0.9, 1.0, 1.0);

uniform sampler2D noise_texture : repeat_enable;
uniform float swirl_speed_1 = 1.5;
uniform float swirl_speed_2 = -2.2;

uniform float noise_scale = 2.0;
uniform float displacement_scale = 0.08;
uniform float fresnel_power = 3.0;
uniform float energy_sharpness : hint_range(1.0, 10.0) = 4.0;

varying float noise_val;

void vertex() {
	// Fast, chaotic swirling UV coordinates
	vec2 uv_swirl1 = UV * noise_scale + vec2(TIME * swirl_speed_1, TIME * swirl_speed_1 * 0.5);
	vec2 uv_swirl2 = UV * noise_scale + vec2(TIME * swirl_speed_2 * 0.3, TIME * swirl_speed_2);
	
	// Blend two opposing noises for that chaotic turbulent look
	float n1 = texture(noise_texture, uv_swirl1).r;
	float n2 = texture(noise_texture, uv_swirl2).r;
	noise_val = mix(n1, n2, 0.5);
	
	// Displace vertices wildly outward to create the erratic, unstable wind shape
	VERTEX += NORMAL * noise_val * displacement_scale;
}

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

void fragment() {
	// Re-sample swirling noise in fragment for high-detail surface chakra filaments
	vec2 uv_swirl1 = UV * noise_scale * 1.5 + vec2(TIME * swirl_speed_1 * 1.2);
	vec2 uv_swirl2 = UV * noise_scale * 1.5 + vec2(TIME * swirl_speed_2 * 1.5);
	float f_noise = mix(texture(noise_texture, uv_swirl1).r, texture(noise_texture, uv_swirl2).r, 0.5);
	
	// Create sharp, distinct wind streaks/filaments using a power function
	float wind_streaks = pow(f_noise, energy_sharpness);
	
	// Fresnel for the glowing outer shell boundaries
	float f_edge = fresnel(fresnel_power, NORMAL, VIEW);
	
	// Combine the edge glow with the inner spinning chakra streaks
	float final_energy = clamp(wind_streaks + f_edge * 0.4, 0.0, 1.0);
	
	// Mix colors: base core color, flashed bright spots, and overall alpha transparency
	vec3 final_color = mix(core_color.rgb, flash_color.rgb, wind_streaks * 1.5);
	
	ALBEDO = final_color;
	// Make it bright and glowing (Emission)
	EMISSION = final_color * (final_energy * 2.5); 
	
	// A dynamic transparency so it feels like compressed, semi-translucent air
	ALPHA = clamp(final_energy * core_color.a, 0.1, 0.95);
	
	ROUGHNESS = 0.1;
	METALLIC = 0.0;
}