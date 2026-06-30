shader_type spatial;

uniform vec3 rock_color : source_color = vec3(0.15, 0.1, 0.08);
uniform vec3 crack_color : source_color = vec3(0.0, 0.8, 0.3);
uniform float metallic : hint_range(0.0,1.0) = 0.1;
uniform float roughness : hint_range(0.0,1.0) = 0.9;
uniform sampler2D rock_normal;
uniform sampler2D noise_texture;
uniform float noise_scale = 1.5;
uniform float crack_sharpness : hint_range(1.0, 20.0) = 7.0;
uniform float crack_glow_intensity = 3.0;
uniform float mountain_height = 0.2; 
varying float height_mask;
void vertex() {
	float noise = texture(noise_texture, UV * noise_scale).r;
	height_mask = smoothstep(0.4, 0.6, noise);
	VERTEX += NORMAL * height_mask * mountain_height;
}

void fragment() {
	float noise_detail = texture(noise_texture, UV * noise_scale * 2.0).r;
	float crack_line = 1.0 - height_mask;
	float pulse = sin(TIME * 2.0) * 0.2 + 0.8;
	float active_cracks = pow(crack_line * noise_detail, crack_sharpness) * pulse;
	vec3 rock_n = texture(rock_normal, UV * 4.0).rgb;
	vec3 final_albedo = mix(rock_color, crack_color, active_cracks);
	ALBEDO = final_albedo;
	METALLIC = metallic;
	ROUGHNESS = mix(roughness, 0.2, active_cracks);
	NORMAL_MAP = mix(rock_n, vec3(0.5, 0.5, 1.0), active_cracks);
	EMISSION = crack_color * active_cracks * crack_glow_intensity;
}
