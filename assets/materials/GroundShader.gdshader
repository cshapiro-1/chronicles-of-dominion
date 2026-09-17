shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 sand_color : source_color = vec4(0.48, 0.40, 0.28, 1.0);
uniform vec4 rock_color : source_color = vec4(0.32, 0.26, 0.19, 1.0);
uniform vec4 mud_color : source_color = vec4(0.24, 0.20, 0.14, 1.0);
uniform float roughness : hint_range(0.0, 1.0) = 0.92;

void fragment() {
	vec2 uv_world = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xz;
	
	// Multi-frequency noise approximation
	float n1 = sin(uv_world.x * 0.15) * cos(uv_world.y * 0.15);
	float n2 = sin(uv_world.x * 0.6 + uv_world.y * 0.4) * 0.5 + 0.5;
	float n3 = sin(uv_world.x * 2.5) * cos(uv_world.y * 2.5) * 0.2;
	
	float combined = clamp(n1 * 0.5 + n2 * 0.4 + n3 + 0.5, 0.0, 1.0);
	
	vec3 col = mix(sand_color.rgb, rock_color.rgb, combined);
	
	// Darker silt along central river bank
	float dist_to_river = abs(uv_world.x + uv_world.y * 0.5);
	if (dist_to_river < 12.0) {
		float silt_factor = 1.0 - (dist_to_river / 12.0);
		col = mix(col, mud_color.rgb, silt_factor * 0.55);
	}
	
	ALBEDO = col;
	ROUGHNESS = roughness;
	METALLIC = 0.02;
	SPECULAR = 0.1;
}
