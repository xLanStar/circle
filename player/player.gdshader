shader_type canvas_item;

uniform vec3 color : source_color;

void fragment() {
	float d = length(UV - 0.5);
	COLOR = vec4(mix(color, vec3(0), step(0.45, d)), 1.0 - step(0.5, d));
}