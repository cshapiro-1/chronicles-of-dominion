shader_type spatial;
render_mode cull_disabled, depth_draw_opaque;

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap;
uniform float wind_speed = 1.8;
uniform float wind_strength = 0.12;
uniform float alpha_scissor_threshold = 0.35;

void vertex() {
	if (VERTEX.y > 2.0) {
		float sway = sin(TIME * wind_speed + VERTEX.x * 0.5 + VERTEX.z * 0.5) * wind_strength * (VERTEX.y - 2.0);
		VERTEX.x += sway;
		VERTEX.z += sway * 0.6;
	}
}

void fragment() {
	vec4 tex = texture(albedo_texture, UV);
	ALBEDO = tex.rgb;
	ALPHA = tex.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
	ROUGHNESS = 0.55;
}
