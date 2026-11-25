# 0018 — Animação em camadas com AnimationTree montada em código

- **Data**: 2026-11
- **Status**: aceita

## Contexto
O `CharacterAnimator` tocava um clipe de corpo inteiro no `AnimationPlayer` do modelo. Com a
guarda erguida, o clipe de guarda vencia a locomoção: o capanga e o ladrão na cautela e o player
com o escudo andavam com as pernas paradas, deslizando. Os três personagens usam o mesmo rig do
KayKit, em que o tronco, os braços e a cabeça descendem do osso `spine` e as pernas, do `hips`.

## Decisão
- O `CharacterAnimator` monta em código, no `_ready`, uma `AnimationTree` filha dele, ligada aos
  clipes do `AnimationPlayer` do modelo. Nenhuma cena guarda a árvore.
- Duas camadas: a de baixo (uma transição entre todos os clipes, com escala de velocidade) toca o
  corpo inteiro; a de cima (guarda ou defesa) entra por um `Blend2` filtrado nos ossos de
  `AnimationSet.upper_body_root` para baixo na hierarquia, com peso suavizado.
- A escolha dos clipes de cada camada continua em regras puras (`AnimationRules`), e a dos ossos,
  em `SkeletonRegions`.

## Alternativas descartadas
- **Segundo `AnimationPlayer` com a guarda sem as trilhas das pernas**: o resultado depende da
  ordem de processamento dos nós e não há mistura suave entre as camadas.
- **`AnimationTree` montada no editor, em cada `.tscn`**: três cenas com recursos grandes
  editados à mão e duplicados; em código há uma fonte só, igual para todo personagem.

## Consequências
Todo personagem com `CharacterAnimator` ganha as camadas sem mexer na cena. Outro clipe na parte
de cima (por exemplo, o golpe durante o avanço da investida) é uma entrada a mais na transição de
cima e uma regra em `AnimationRules`. A árvore não aparece no editor: para inspecioná-la, só com
o jogo rodando (aba Remote).
