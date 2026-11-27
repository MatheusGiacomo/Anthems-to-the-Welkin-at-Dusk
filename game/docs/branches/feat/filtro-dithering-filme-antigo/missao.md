# Missão da branch feat/filtro-dithering-filme-antigo

Uma branch, um propósito: o que não couber nesta missão vai para outra branch.

## Objetivo
Dar ao jogo uma atmosfera sombria com um pós-processamento em tela cheia por cima do mundo 3D:
dithering pixelado em paleta reduzida (cinzas levemente quentes, com realce para vermelhos e
laranjas saturados) e, por cima, um filtro de filme de rolo antigo.

## Inclui
- Shaders de dithering e de filme antigo (grão, riscos, poeira, tremulação, oscilação do quadro,
  desfoque nas bordas, vinheta e cantos arredondados).
- Cena do filtro na pasta nova `filters/`, com os ajustes em materiais editáveis no inspetor.
- Instância do filtro na sequência de fases (cena principal) e na arena de teste.
- Teste de cena da estrutura do filtro e nota em `docs/sistemas/`.

## Não inclui
- Mudar arte, iluminação, câmera ou gameplay.
- Filtro sobre a UI (HUD e painel de debug ficam por cima e legíveis).

## Pastas
- filters/
- levels/
- arena/
- test/scenes/
- docs/

## Arquivos protegidos autorizados
- (nenhum)

## Estado
- Feito: filtro de tela em `filters/` (dois passes: dithering e filme antigo), instanciado na
  sequência de fases e na arena, com teste de cena e nota em `docs/sistemas/filtro-de-tela.md`.
- Ajustado após ver no jogo: pixel de 3 px e desfoque fraco, só perto das bordas.
- Falta: validar jogando e afinar os parâmetros dos materiais se preciso.

## Decisões propostas
- (nenhuma; cada uma em decisoes/<titulo>.md nesta pasta, sem número)

## Validar jogando
- Leitura dos personagens com o pixel de 3 px na câmera de cima.
- O laranja do preparo da investida continua colorido; o amarelo da vulnerabilidade vira cinza
  claro: conferir se ainda se lê.
- FPS com os dois passes em tela cheia (renderer Compatibility).
- Se riscos e tremulação cansam em sessões longas (`streak_strength`, `flicker_strength`).
- Bordas: vinheta (`vignette_strength`) e desfoque (`edge_blur_radius`) não atrapalham a visão.
