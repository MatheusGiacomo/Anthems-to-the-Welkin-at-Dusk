# Filtro de tela

## Propósito
Dar ao jogo uma atmosfera sombria de filme antigo: por cima do mundo 3D, a imagem é pixelada,
reduzida a poucos tons de cinza com dithering e passa por um filtro de filme de rolo. Não muda
nenhuma regra de jogo, e a UI fica por cima, sem filtro.

## Componentes
- `filters/screen_filter.tscn` (`ScreenFilter`, CanvasLayer, camada -1): dois passes em tela
  cheia, sem script. A camada negativa desenha depois do 3D e antes de toda UI (camadas a partir
  de 1).
  - `Dither` (ColorRect) com `filters/dither_material.tres` (`filters/dither.gdshader`): lê a tela
    e devolve a versão pontilhada.
  - `BackBufferCopy` (modo viewport): copia a tela já pontilhada, para o passe seguinte ler o
    resultado do `Dither`, não a imagem original.
  - `OldFilm` (ColorRect) com `filters/old_film_material.tres` (`filters/old_film.gdshader`):
    aplica o filme sobre a cópia.
- Instanciado em `levels/level_sequence.tscn` (cena principal) e em `arena/arena.tscn`.

## Regras
Todos os valores são parâmetros dos materiais (`.tres`), editáveis no inspetor; os padrões ficam
nos `uniform` dos shaders. Tamanhos em pixels são medidos na altura de referência (1080) e
crescem com a janela.

**Dither** (nesta ordem):
1. Pixeliza em células de `pixel_size` (3 px) e lê a cor do centro de cada célula.
2. Luminância com `brightness`, `contrast` e `gamma`.
3. Quantiza em `tone_levels` (4) tons com limiar de Bayer 8x8 (`dither_strength` 0 = faixas
   chapadas, 1 = pontos completos).
4. Pinta numa rampa de três cores: `shadow_color` → `mid_color` → `light_color`.
5. **Realce:** cor com matiz a até `accent_hue_width` (0,09) do vermelho, saturação acima de
   `accent_min_saturation` (0,55) e brilho acima de `accent_min_value` (0,6) vai para a rampa
   `accent_shadow_color` → `accent_color`, também pontilhada. O brilho mínimo é o que separa o
   laranja do preparo da investida dos marrons (troncos, caminho), que têm o mesmo matiz.

**Filme antigo** (o aleatório muda a `film_fps` = 16 quadros por segundo, não a cada quadro do jogo):
- oscilação do quadro (`weave_amount`) e tremulação de brilho (`flicker_strength`);
- manchas grandes e lentas de exposição desigual (`mottle_*`, `stain_color`);
- traços curtos inclinados na emulsão (`streak_*`, 58°);
- até 3 riscos verticais por quadro, claros ou escuros (`scratch_*`);
- poeira: no máximo um grão por célula de `dust_cell_size` (`dust_*`);
- granulação na grade de `grain_size`, igual ao pixel do dither;
- desfoque crescente a partir de `edge_blur_start` do centro, vinheta e cantos arredondados
  (`corner_radius`) com moldura escura.

## Sinais
Nenhum.

## Testes
- `test/scenes/screen_filter_test.gd`: camada abaixo da UI, passes cobrindo a tela sem capturar
  o mouse e com material, e cópia da tela entre o dither e o filme.
- O visual em si não é testável: valide jogando.
