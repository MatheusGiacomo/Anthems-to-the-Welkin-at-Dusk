# 0017 — Fases como cenas filhas de uma sequência persistente

- **Data**: 2026-11
- **Status**: aceita

## Contexto
O jogo passa a ter fases encadeadas: o player entra por um lado, enfrenta os inimigos e sai pelo
outro, com a tela escurecendo e clareando na troca. A câmera, a transição e o painel de debug
são os mesmos em todas as fases, e no futuro o estado do player (vida, itens) pode precisar
atravessar as fases.

## Decisão
- A Main Scene é `levels/level_sequence.tscn` (`LevelSequence`): tem a câmera, a tela de
  transição (`ScreenFade`), o painel de debug e um nó vazio (`LevelSlot`) onde fica a fase atual.
- Cada fase é uma cena com `Level` na raiz (`levels/level_0N.tscn`): chão, bordas, props, início
  do player, encontro e saída (`LevelExit`). A fase não conhece as outras; avisa `exit_reached`.
- A `LevelSequence` troca a fase (libera a atual e instancia a próxima) por trás do
  escurecimento, cria um player novo no início dela e enquadra a câmera na `view_bounds` da fase.
- A ordem das fases é uma lista exportada (`levels`), editável no inspetor.

## Alternativas descartadas
- **`change_scene_to_file` com um autoload para a transição**: exige um autoload só para o fade
  e perde o nó raiz que sobrevive à troca de fase.
- **Todas as fases numa cena só, com a câmera indo de uma para outra**: cena enorme, difícil de
  editar, e as fases não podem ser abertas e testadas sozinhas.

## Consequências
Uma fase nova é uma cena `Level` acrescentada à lista. Câmera, transição e debug ficam num lugar
só. O player é recriado a cada fase (vida cheia); levar estado de uma fase para outra vai exigir
guardar esse estado na `LevelSequence`.
