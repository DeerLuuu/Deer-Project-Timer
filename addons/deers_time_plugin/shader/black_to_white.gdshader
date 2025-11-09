shader_type canvas_item;

void fragment() {
	if (COLOR.a >= 0.8) COLOR = vec4(1, 1, 1, 1);
}
