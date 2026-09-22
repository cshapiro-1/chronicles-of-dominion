shader_type spatial;
render_mode specular_schlick_ggx, depth_draw_always;

uniform vec4 water_deep_color : source_color = vec4(0.12, 0.28, 0.35, 0.92);
uniform vec4 water_shallow_color : source_color = vec4(0.25, 0.55, 0.60, 0.75);
uniform vec4 foam_color : source_color = vec4(0.88, 0.95, 0.98, 1.0);
uniform float wave_speed = 0.45;
uniform float wave_frequency = 4.0;
uniform float wave_amplitude = 0.08;
uniform float roughness : hint_range(0.0, 1.0) = 0.08;
uniform float metallic : hint_range(0.0, 1.0) = 0.2;

void vertex() {
	float wave1 = sin(VERTEX.x * wave_frequency + TIME * wave_speed * 2.0) * wave_amplitude;
	float wave2 = cos(VERTEX.z * wave_frequency * 0.8 + TIME * wave_speed * 1.5) * wave_amplitude * 0.6;
	VERTEX.y += wave1 + wave2;
	NORMAL = normalize(vec3(-wave1 * 2.0, 1.0, -wave2 * 2.0));
}

void fragment() {
	vec2 flow_uv1 = UV * 8.0 + vec2(0.0, TIME * wave_speed * 0.2);
	vec2 flow_uv2 = UV * 12.0 - vec2(TIME * wave_speed * 0.15, TIME * wave_speed * 0.1);
	
	float wave_mix = sin(flow_uv1.y * 6.28) * 0.5 + 0.5;
	vec3 base_color = mix(water_deep_color.rgb, water_shallow_color.rgb, wave_mix * 0.4);
	
	ALBEDO = base_color;
	ROUGHNESS = roughness;
	METALLIC = metallic;
	SPECULAR = 0.6;
	ALPHA = water_deep_color.a;
}
