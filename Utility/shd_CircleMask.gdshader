shader_type canvas_item;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	
	float dist = distance(vec2(0.5, 0.5), UV);
	float circ = smoothstep(dist - 0.0125, dist + 0.0125, 0.5);
	
	COLOR = circ * tex;
}
