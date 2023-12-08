shader_type canvas_item;

uniform vec3 color : source_color;

void fragment() {
	float circle = 1.0 - step(0.5, length(UV - 0.5));
	COLOR = vec4(color, circle);
}