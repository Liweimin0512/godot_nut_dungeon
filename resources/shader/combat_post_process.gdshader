shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 5.0) = 0.0;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float brightness : hint_range(0.0, 2.0) = 1.0;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void fragment() {
	// 高斯模糊
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec2 pixel_size = 1.0 / vec2(textureSize(SCREEN_TEXTURE, 0));

	color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(pixel_size.x, 0.0) * blur_amount);
	color += texture(SCREEN_TEXTURE, SCREEN_UV - vec2(pixel_size.x, 0.0) * blur_amount);
	color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, pixel_size.y) * blur_amount);
	color += texture(SCREEN_TEXTURE, SCREEN_UV - vec2(0.0, pixel_size.y) * blur_amount);
	color /= 5.0;

	// 晕影效果
	vec2 uv = SCREEN_UV;
	float vignette = distance(uv, vec2(0.5));
	vignette = smoothstep(0.5, 1.0, vignette);
	color.rgb *= (1.0 - vignette * vignette_intensity);

	// 亮度调整
	color.rgb *= brightness;

	COLOR = color;
}