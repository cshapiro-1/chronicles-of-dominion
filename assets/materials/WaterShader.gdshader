shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 deep_color : source_color = vec4(0.08, 0.18, 0.22, 1.0);
uniform vec4 shallow_color : source_color = vec4(0.25, 0.38, 0.32, 0.9);
uniform float metallic : hint_range(0.0, 1.0) = 0.1;
uniform float roughness : hint_range(0.0, 1.0) = 0.15;
uniform float wave_speed : hint_range(0.0, 2.0) = 0.4;
uniform float wave_scale : hint_range(0.1, 10.0) = 2.0;

void vertex() {
	float wave1 = sin(VERTEX.x * wave_scale + TIME * wave_speed) * 0.08;
	float wave2 = cos(VERTEX.z * wave_scale * 1.5 + TIME * wave_speed * 1.2) * 0.06;
	VERTEX.y += wave1 + wave2;
}

void fragment() {
	vec2 uv_moved = UV * 4.0 + vec2(TIME * 0.03 * wave_speed, TIME * 0.02 * wave_speed);
	float n = sin(uv_moved.x * 10.0) * cos(uv_moved.y * 10.0) * 0.5 + 0.5;
	
	ALBEDO = mix(shallow_color.rgb, deep_color.rgb, n * 0.6 + 0.4);
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = 0.6;
	NORMAL = normalize(vec3(sin(uv_moved.x * 8.0) * 0.1, 1.0, cos(uv_moved.y * 8.0) * 0.1));
}
