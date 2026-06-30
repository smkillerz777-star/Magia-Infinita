shader_type spatial;
render_mode blend_add, depth_draw_always, cull_back, unshaded;

uniform vec4 core_color : source_color = vec4(1.0, 1.0, 0.9, 1.0);
uniform vec4 edge_color : source_color = vec4(1.0, 0.8, 0.2, 1.0);

uniform sampler2D noise_texture;
uniform float pulse_speed = 1.5;
uniform float fresnel_power : hint_range(0.1, 5.0) = 2.5;
uniform float glow_intensity = 2.0;

void fragment() {
	float fresnel = pow((1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0)), fresnel_power);
	float core_fade = 1.0 - fresnel;
	vec2 moving_uv = UV + vec2(TIME * pulse_speed * 0.1, TIME * pulse_speed * -0.05);
	float noise = texture(noise_texture, moving_uv).r;
	float final_glow = core_fade * mix(0.7, 1.3, noise);
	vec3 final_color = mix(edge_color.rgb, core_color.rgb, final_glow) * glow_intensity;
	ALBEDO = final_color;
	ALPHA = clamp(final_glow * core_color.a, 0.0, 1.0);
}