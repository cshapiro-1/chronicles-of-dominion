shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D terrain_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform float texture_scale = 0.0075;
uniform float roughness : hint_range(0.0, 1.0) = 0.88;

void fragment() {
	vec2 uv_world = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xz;
	vec2 uv_map = uv_world * texture_scale + vec2(0.5, 0.5);
	
	vec4 map_col = texture(terrain_texture, uv_map);
	
	ALBEDO = map_col.rgb;
	ROUGHNESS = roughness;
	METALLIC = 0.02;
	SPECULAR = 0.15;
}
