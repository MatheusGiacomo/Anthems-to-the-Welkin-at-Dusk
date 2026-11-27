// Segundo passe do filtro de tela: sobre a imagem já pontilhada, imita um filme de rolo antigo
// projetado. O quadro oscila e tremula, a emulsão tem manchas, riscos e poeira, há granulação,
// as bordas ficam desfocadas e escuras e os cantos são arredondados como na janela do projetor.
// Tudo que é aleatório muda em "quadros de filme" (film_fps), não a cada quadro do jogo.
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

group_uniforms projector;
uniform float film_fps : hint_range(1.0, 60.0, 1.0) = 16.0;
// Alturas e tamanhos em pixels são medidos na altura de referência e acompanham a janela.
uniform float reference_height : hint_range(240.0, 4320.0, 1.0) = 1080.0;
// Deslocamento máximo do quadro por quadro de filme, em pixels.
uniform float weave_amount : hint_range(0.0, 20.0, 0.1) = 2.0;
// Variação máxima do brilho entre quadros (0,1 = ±5%).
uniform float flicker_strength : hint_range(0.0, 1.0, 0.01) = 0.1;

group_uniforms emulsion;
// Manchas grandes e lentas de exposição desigual.
uniform float mottle_strength : hint_range(0.0, 1.0, 0.01) = 0.22;
uniform float mottle_scale : hint_range(1.0, 20.0, 0.1) = 3.5;
// Quadros de filme que uma mancha leva para se transformar.
uniform float mottle_drift_frames : hint_range(1.0, 200.0, 1.0) = 40.0;
uniform vec4 stain_color : source_color = vec4(0.12, 0.09, 0.11, 1.0);

group_uniforms streaks;
// Traços curtos e inclinados riscados na emulsão.
uniform float streak_density : hint_range(0.0, 1.0, 0.01) = 0.35;
uniform float streak_strength : hint_range(0.0, 1.0, 0.01) = 0.45;
uniform float streak_angle_degrees : hint_range(-90.0, 90.0, 1.0) = 58.0;
uniform float streak_length : hint_range(4.0, 200.0, 1.0) = 34.0;
uniform float streak_width : hint_range(1.0, 10.0, 0.1) = 2.2;
uniform float streak_spacing : hint_range(2.0, 60.0, 0.5) = 9.0;
uniform vec4 streak_color : source_color = vec4(0.18, 0.15, 0.17, 1.0);

group_uniforms scratches;
// Riscos verticais longos, que atravessam o quadro.
uniform float scratch_probability : hint_range(0.0, 1.0, 0.01) = 0.45;
uniform float scratch_strength : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float scratch_width : hint_range(0.5, 8.0, 0.1) = 1.5;
uniform vec4 scratch_light_color : source_color = vec4(0.95, 0.94, 0.9, 1.0);
uniform vec4 scratch_dark_color : source_color = vec4(0.1, 0.08, 0.09, 1.0);

group_uniforms dust;
uniform float dust_probability : hint_range(0.0, 1.0, 0.01) = 0.06;
uniform float dust_strength : hint_range(0.0, 1.0, 0.01) = 0.75;
// Lado da célula onde no máximo um grão de poeira aparece, em pixels.
uniform float dust_cell_size : hint_range(10.0, 400.0, 1.0) = 90.0;
uniform float dust_max_radius : hint_range(0.5, 20.0, 0.1) = 4.0;

group_uniforms grain;
uniform float grain_strength : hint_range(0.0, 1.0, 0.01) = 0.12;
// Igual ao pixel do dithering, para o grão casar com a grade de pontos.
uniform float grain_size : hint_range(1.0, 16.0, 1.0) = 3.0;

group_uniforms lens;
// Distância ao centro (0 = centro, 1 = meio da borda) onde o desfoque começa.
uniform float edge_blur_start : hint_range(0.0, 1.5, 0.01) = 0.85;
uniform float edge_blur_radius : hint_range(0.0, 40.0, 0.1) = 4.0;
uniform float vignette_start : hint_range(0.0, 1.5, 0.01) = 0.55;
uniform float vignette_strength : hint_range(0.0, 1.0, 0.01) = 0.55;
uniform vec4 vignette_color : source_color = vec4(0.12, 0.09, 0.11, 1.0);

group_uniforms frame;
uniform float corner_radius : hint_range(0.0, 300.0, 1.0) = 90.0;
uniform float frame_softness : hint_range(0.5, 60.0, 0.5) = 14.0;
uniform vec4 frame_color : source_color = vec4(0.05, 0.04, 0.05, 1.0);

const int MAX_SCRATCHES = 3;
const int BLUR_TAPS = 8;

// Número pseudoaleatório em [0, 1) para `p` (hash sem seno, estável em GPUs fracas).
float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

// Ruído de valor suave em [0, 1).
float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	float a = hash12(i);
	float b = hash12(i + vec2(1.0, 0.0));
	float c = hash12(i + vec2(0.0, 1.0));
	float d = hash12(i + vec2(1.0, 1.0));
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float rounded_box_distance(vec2 p, vec2 half_size, float radius) {
	vec2 q = abs(p) - half_size + radius;
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
}

vec3 sample_blurred(vec2 uv, float radius_px, vec2 pixel) {
	vec3 sum = texture(screen_texture, uv).rgb;
	if (radius_px < 0.5) {
		return sum;
	}
	for (int i = 0; i < BLUR_TAPS; i++) {
		float angle = TAU * float(i) / float(BLUR_TAPS);
		vec2 offset = vec2(cos(angle), sin(angle)) * radius_px * pixel;
		sum += texture(screen_texture, uv + offset).rgb;
		sum += texture(screen_texture, uv + offset * 0.5).rgb;
	}
	return sum / float(BLUR_TAPS * 2 + 1);
}

float streak_mask(vec2 px, float frame, float scale) {
	float angle = radians(streak_angle_degrees);
	mat2 rotation = mat2(vec2(cos(angle), sin(angle)), vec2(-sin(angle), cos(angle)));
	vec2 p = rotation * px;
	float spacing = streak_spacing * scale;
	float length_px = streak_length * scale;
	// Cada coluna inclinada é deslocada ao acaso para os traços não se alinharem.
	float column = floor(p.x / spacing);
	p.y += hash12(vec2(column, 7.0)) * length_px;
	vec2 cell = vec2(column, floor(p.y / length_px));
	vec2 seed = cell + vec2(frame * 0.37, frame * 0.91);
	if (hash12(seed) > streak_density) {
		return 0.0;
	}
	vec2 local = vec2(fract(p.x / spacing) * spacing, fract(p.y / length_px));
	float dash_length = mix(0.3, 0.9, hash12(seed + 3.1));
	float center_x = spacing * 0.5;
	float across = 1.0 - smoothstep(streak_width * scale * 0.3, streak_width * scale * 0.5, abs(local.x - center_x));
	float along = smoothstep(0.0, 0.1, local.y) * (1.0 - smoothstep(dash_length - 0.1, dash_length, local.y));
	return across * along * mix(0.4, 1.0, hash12(seed + 5.7));
}

void fragment() {
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	float scale = screen_size.y / reference_height;
	float frame = mod(floor(TIME * film_fps), 1000.0);

	vec2 weave = (vec2(hash12(vec2(frame, 1.0)), hash12(vec2(frame, 2.0))) - 0.5) * weave_amount * scale;
	vec2 px = FRAGCOORD.xy + weave;
	vec2 uv = px * SCREEN_PIXEL_SIZE;

	// Distância ao centro com 1 no meio da borda mais próxima no eixo menor.
	vec2 centered = (SCREEN_UV - 0.5) * 2.0;
	centered.x *= screen_size.x / screen_size.y;
	float center_distance = length(centered);

	float blur = smoothstep(edge_blur_start, edge_blur_start + 0.8, center_distance) * edge_blur_radius * scale;
	vec3 color = sample_blurred(uv, blur, SCREEN_PIXEL_SIZE);

	float mottle_time = frame / mottle_drift_frames;
	float mottle = value_noise(SCREEN_UV * mottle_scale + vec2(mottle_time, mottle_time * 0.7));
	mottle = smoothstep(0.45, 1.0, mottle);
	color = mix(color, stain_color.rgb, mottle * mottle_strength);

	color *= 1.0 + (hash12(vec2(frame, 3.0)) - 0.5) * flicker_strength;

	color = mix(color, streak_color.rgb, streak_mask(FRAGCOORD.xy, frame, scale) * streak_strength);

	for (int i = 0; i < MAX_SCRATCHES; i++) {
		vec2 seed = vec2(frame, float(i) * 13.0);
		if (hash12(seed) < scratch_probability) {
			float x = hash12(seed + 1.0) * screen_size.x;
			x += sin(FRAGCOORD.y * 0.01 + hash12(seed + 2.0) * TAU) * 3.0 * scale;
			float line = 1.0 - smoothstep(0.0, scratch_width * scale, abs(FRAGCOORD.x - x));
			// O risco some e volta ao longo da altura, como emulsão raspada de forma irregular.
			line *= smoothstep(0.3, 0.7, value_noise(vec2(FRAGCOORD.y * 0.02 / scale, seed.x + seed.y)));
			vec3 scratch = hash12(seed + 4.0) > 0.5 ? scratch_light_color.rgb : scratch_dark_color.rgb;
			color = mix(color, scratch, line * scratch_strength);
		}
	}

	float dust_size = dust_cell_size * scale;
	vec2 dust_cell = floor(FRAGCOORD.xy / dust_size);
	vec2 dust_seed = dust_cell + frame * 1.618;
	if (hash12(dust_seed) < dust_probability) {
		vec2 dust_center = (dust_cell + vec2(hash12(dust_seed + 1.0), hash12(dust_seed + 2.0))) * dust_size;
		float radius = mix(0.5, dust_max_radius, hash12(dust_seed + 3.0)) * scale;
		float speck = 1.0 - smoothstep(radius * 0.6, radius, distance(FRAGCOORD.xy, dust_center));
		vec3 dust = hash12(dust_seed + 4.0) > 0.35 ? scratch_dark_color.rgb : scratch_light_color.rgb;
		color = mix(color, dust, speck * dust_strength);
	}

	vec2 grain_cell = floor(FRAGCOORD.xy / max(1.0, round(grain_size * scale)));
	color += (hash12(grain_cell + frame * 17.0) - 0.5) * grain_strength;

	float vignette = smoothstep(vignette_start, vignette_start + 1.0, center_distance);
	color = mix(color, vignette_color.rgb, vignette * vignette_strength);

	float edge = rounded_box_distance(FRAGCOORD.xy - screen_size * 0.5, screen_size * 0.5, corner_radius * scale);
	color = mix(color, frame_color.rgb, smoothstep(-frame_softness * scale, 0.0, edge));

	COLOR = vec4(clamp(color, 0.0, 1.0), 1.0);
}
