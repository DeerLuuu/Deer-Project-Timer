shader_type canvas_item;

uniform bool is_ui;												// 是否为UI
uniform float radius : hint_range(0.0, 1.0) = 0.5;				// 泛光半径
uniform float edge_width : hint_range(0.0, 0.5) = 0.1;			// 过渡宽度
uniform float brightness : hint_range(0.0, 5.0) = 1.5;			// 泛光亮度
uniform vec3 glow_color : source_color = vec3(1.0, 0.9, 0.8);	// 泛光颜色

void vertex() {
}

void fragment() {
	// 获取当前节点的大小（像素单位）
	vec2 size = TEXTURE_PIXEL_SIZE;
	
	// 计算宽高比（宽度/高度）
	float aspect_ratio = size.x / size.y;
	
	// 计算中心点
	vec2 center = vec2(0.5, 0.5);
	
	// 将UV坐标转换为中心点的偏移
	vec2 uv_centered = UV - center;
	
	// 按宽高比缩放坐标，使计算距离时考虑实际长宽比
	uv_centered.x *= aspect_ratio;
	
	// 计算归一化距离（在椭圆坐标系中）
	float dist = length(uv_centered);
	
	// 计算渐变强度（边缘亮，中心暗）
	float t = smoothstep(radius - edge_width, radius + edge_width, dist);
	t = pow(t, 2.0); // 使渐变更平滑
	
	if (is_ui){
		COLOR = vec4(glow_color, 1.0) * t * brightness;
	}
	else {
		vec4 original_color = texture(TEXTURE, UV);
		vec4 glow = vec4(glow_color, 1.0) * t * brightness;
		COLOR = original_color + glow;
	}
}