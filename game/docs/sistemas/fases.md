# Fases

## Propósito
Encadear cenas jogáveis: o player entra por um lado (oeste), segue o caminho enfrentando os
inimigos posicionados e sai pelo outro (leste). A saída só abre sem inimigos vivos. A troca de
fase escurece e clareia a tela. Decisão 0017.

## Componentes
- `levels/level_sequence.gd` + `.tscn` (`LevelSequence`, **Main Scene**): carrega as fases da lista `levels` em ordem, cria o player no início de cada uma, enquadra a `FixedCamera` em `view_bounds` da fase e liga o painel de debug. Trata o F5 (reaparecer os inimigos da fase atual).
- `levels/level.gd` (`Level`): raiz de cada fase. `start(player)` dá o alvo ao encontro e spawna; `get_player_start()`; `respawn_enemies()`; `calm()`. Abre a saída quando o encontro emite `all_enemies_died` (ou na hora, se não houver inimigos).
- `levels/level_exit.gd` + `.tscn` (`LevelExit`): barreira vermelha translúcida (StaticBody3D na camada `world`) com `opening_width` metros ao longo de Z local e, logo depois dela em +X local, uma área que detecta só o player (máscara `player`). `open()` tira a barreira; com ela aberta, a entrada do player emite `player_entered`.
- `ui/transition/screen_fade.gd` + `.tscn` (`ScreenFade`): CanvasLayer (camada 10) com um ColorRect preto; `fade_out()` e `fade_in()` podem ser aguardados (`fade_out_time` e `fade_in_time`, 0,4 s cada).
- `levels/props/tree.tscn` e `rock.tscn`: props placeholder com colisão na camada `world` (barram corpos e flechas). Árvore: tronco (cilindro) e copa (esfera); pedra: caixa.

## Fases
Todas com chão de 44×24 m (de -22 a 22 em X, de -12 a 12 em Z), bordas, o player começando a 2 m da borda oeste olhando para leste e a saída (6 m de abertura) na borda leste.

| Cena | Caminho | Inimigos |
|---|---|---|
| `level_01.tscn` | Estrada reta pela floresta (z = 0) | 2 capangas, 1 ladrão |
| `level_02.tscn` | Caminho em S entre pedras (entra em z = 6, passa por z = -6, sai em z = 6) | 2 capangas, 2 ladrões |
| `level_03.tscn` | Estrada até uma clareira com quatro pedras e saída do outro lado | 3 capangas, 2 ladrões |

Os props foram espalhados por um gerador fora do projeto; daqui em diante, as cenas são editadas no editor. As árvores ficam a mais de ~2,5 m ao sul do caminho, para a copa não cobrir o caminho na tela (a câmera vem do sul).

## Regras
- **Saída:** fechada enquanto houver inimigo vivo na fase; abre quando o último morre. O F5 reaparece os inimigos e fecha a saída de novo.
- **Troca de fase:** com o player na área da saída aberta, ele para, a tela escurece, a fase é trocada pela próxima (depois da última, volta à primeira) e a tela clareia.
- **Morte do player:** os inimigos o largam; depois de `restart_delay` (1 s), a mesma troca recarrega a fase atual.
- O player é recriado a cada fase, com vida cheia.
- Inimigos sem navmesh: vão em linha reta e deslizam nos props (`move_and_slide`).

## Sinais
- `Encounter.all_enemies_died` → `Level._on_encounter_all_enemies_died`: abre a saída.
- `LevelExit.player_entered` → `Level._on_exit_player_entered` → `Level.exit_reached` → `LevelSequence._on_level_exit_reached`: próxima fase.
- `Player.died` → `LevelSequence._on_player_died`: recarrega a fase atual.
- `LevelSequence.level_loaded(index)`: fase carregada (para testes e, no futuro, HUD).

## Testes
- `test/scenes/level_flow_test.gd`: a saída começa fechada, abre depois de matar os inimigos e o player nela leva à fase seguinte.
