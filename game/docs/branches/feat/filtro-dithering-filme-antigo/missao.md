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
(atualizado no /fim: o que está feito e o que falta)

## Decisões propostas
- (nenhuma; cada uma em decisoes/<titulo>.md nesta pasta, sem número)

## Validar jogando
- (atualizado no /fim)
