// Primeiro passe do filtro de tela: pixeliza a imagem do jogo, reduz a poucos tons com dithering
// ordenado (Bayer 8x8) e pinta numa paleta de cinzas levemente quentes. Vermelhos e laranjas
// saturados não viram cinza: passam a uma rampa de realce, para sangue e alertas de combate
// continuarem legíveis.
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

group_uniforms pixel;
// Lado do pixel virtual, em pixels de tela na altura de referência.
uniform float pixel_size : hint_range(1.0, 16.0, 1.0) = 4.0;
// O pixel virtual cresce junto com a janela a partir desta altura (a base do projeto).
uniform float reference_height : hint_range(240.0, 4320.0, 1.0) = 1080.0;

group_uniforms tone;
uniform int tone_levels : hint_range(2, 16) = 4;
uniform float brightness : hint_range(-1.0, 1.0, 0.01) = 0.04;
uniform float contrast : hint_range(0.0, 3.0, 0.01) = 1.5;
// Abaixo de 1 clareia os meios-tons; acima, escurece.
uniform float gamma : hint_range(0.2, 3.0, 0.01) = 1.0;
// 0 = faixas chapadas; 1 = padrão de pontos completo entre os tons.
uniform float dither_strength : hint_range(0.0, 1.0, 0.01) = 1.0;

group_uniforms palette;
uniform vec4 shadow_color : source_color = vec4(0.16, 0.13, 0.15, 1.0);
uniform vec4 mid_color : source_color = vec4(0.56, 0.53, 0.54, 1.0);
uniform vec4 light_color : source_color = vec4(0.93, 0.92, 0.86, 1.0);

group_uniforms accent;
uniform bool accent_enabled = true;
uniform vec4 accent_color : source_color = vec4(0.86, 0.12, 0.13, 1.0);
uniform vec4 accent_shadow_color : source_color = vec4(0.36, 0.05, 0.07, 1.0);
// Matiz central do realce (0 = vermelho) e quanto ele se estende para cada lado; 0,09 alcança
// o laranja do preparo da investida.
uniform float accent_hue_center : hint_range(0.0, 1.0, 0.005) = 0.0;
uniform float accent_hue_width : hint_range(0.0, 0.5, 0.005) = 0.09;
uniform float accent_hue_softness : hint_range(0.001, 0.2, 0.001) = 0.03;
uniform float accent_min_saturation : hint_range(0.0, 1.0, 0.01) = 0.55;
// Marrons têm o mesmo matiz do laranja; o brilho mínimo é o que os deixa de fora do realce.
uniform float accent_min_value : hint_range(0.0, 1.0, 0.01) = 0.6;
// Largura da passagem pontilhada entre o cinza e o realce, em saturação e brilho.
uniform float accent_softness : hint_range(0.001, 0.5, 0.001) = 0.1;
uniform int accent_levels : hint_range(2, 8) = 3;

// Limiar de Bayer em [0, 1) para a célula `cell`; 8x8 montado recursivamente a partir do 2x2.
float bayer2(vec2 cell) {
	cell = floor(cell);
	return fract(dot(cell, vec2(0.5, cell.y * 0.75)));
}

float bayer4(vec2 cell) {
	return bayer2(0.5 * cell) * 0.25 + bayer2(cell);
}

float bayer8(vec2 cell) {
	return bayer4(0.5 * cell) * 0.25 + bayer2(cell);
}

vec3 rgb_to_hsv(vec3 c) {
	vec4 k = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, k.wz), vec4(c.gb, k.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// Leva `value` em [0, 1] ao tom mais próximo de `levels`, deslocado pelo limiar de Bayer.
float quantize(float value, int levels, float threshold) {
	float steps = float(levels - 1);
	return clamp(floor(value * steps + threshold) / steps, 0.0, 1.0);
}

vec3 palette(float tone) {
	if (tone < 0.5) {
		return mix(shadow_color.rgb, mid_color.rgb, tone * 2.0);
	}
	return mix(mid_color.rgb, light_color.rgb, (tone - 0.5) * 2.0);
}

void fragment() {
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	float cell_size = max(1.0, round(pixel_size * screen_size.y / reference_height));
	vec2 cell = floor(FRAGCOORD.xy / cell_size);
	vec2 cell_uv = (cell + 0.5) * cell_size * SCREEN_PIXEL_SIZE;
	vec3 source = texture(screen_texture, cell_uv).rgb;

	float threshold = mix(0.5, bayer8(cell), dither_strength);

	float luma = dot(source, vec3(0.299, 0.587, 0.114));
	luma = clamp((luma - 0.5) * contrast + 0.5 + brightness, 0.0, 1.0);
	luma = pow(luma, gamma);
	vec3 color = palette(quantize(luma, tone_levels, threshold));

	if (accent_enabled) {
		vec3 hsv = rgb_to_hsv(source);
		float hue_distance = abs(hsv.x - accent_hue_center);
		hue_distance = min(hue_distance, 1.0 - hue_distance);
		float in_hue = 1.0 - smoothstep(
			accent_hue_width, accent_hue_width + accent_hue_softness, hue_distance
		);
		float saturated = smoothstep(accent_min_saturation, accent_min_saturation + accent_softness, hsv.y);
		float lit = smoothstep(accent_min_value, accent_min_value + accent_softness, hsv.z);
		float accent_amount = in_hue * saturated * lit;
		// A borda do realce também é pontilhada: compara com o mesmo limiar de Bayer.
		if (accent_amount > threshold) {
			float accent_tone = quantize(hsv.z, accent_levels, threshold);
			color = mix(accent_shadow_color.rgb, accent_color.rgb, accent_tone);
		}
	}

	COLOR = vec4(color, 1.0);
}
