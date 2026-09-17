shader_type spatial;

uniform sampler2D terrain_texture : source_color, filter_linear_mipmap_anisotropic;
uniform float texture_scale = 0.08;
uniform float roughness : hint_range(0.0, 1.0) = 0.9;

void fragment() {
	vec2 uv = UV * texture_scale * 100.0;
	vec4 base_color = texture(terrain_texture, uv);
	
	// Distance from center for subtle desert vignette
	float dist = length(UV - vec2(0.5, 0.5)) * 2.0;
	vec3 warm_tint = vec3(0.72, 0.58, 0.42);
	
	ALBEDO = mix(base_color.rgb, warm_tint, 0.35) * (1.0 - dist * 0.15);
	ROUGHNESS = roughness;
	SPECULAR = 0.15;
}
