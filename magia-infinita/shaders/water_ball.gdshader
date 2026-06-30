shader_type spatial;
uniform vec3 albedo : source_color;
uniform vec3 albedo2 : source_color;
uniform float roughness : hint_range(0.0,1.0) = 0.02;
uniform float metallic : hint_range(0.0,1.0) = 0.0;
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;
uniform vec2 wave_direction = vec2(0.0,2.0);
uniform vec2 wave_direction2 = vec2(1.0,0.0);
uniform float time_scale : hint_range(0.0,2.0,0.005) = 0.025;
float fresnel(float amount,vec3 normal,vec3 view)
{
	return pow((1.0-clamp(dot(normalize(normal),normalize(view)),0.0,1.0)),amount);
}
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float fresnel = fresnel(5.0,NORMAL,VIEW);
	vec3 surface_color = mix(albedo,albedo2,fresnel);
	vec2 time = (TIME * wave_direction) * time_scale;
	vec2 time2 = (TIME * wave_direction2) * time_scale;
	vec3 normal_blend = mix(texture(texture_normal2,UV+time2).rgb,texture(texture_normal,UV+time).rgb,0.5);
	ALBEDO = surface_color;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	NORMAL_MAP = normal_blend;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
