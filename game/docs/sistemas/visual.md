# Visual

## Propósito
Mostrar o combate com personagens animados, sem mudar regra de jogo: o visual só lê o estado dos
componentes.

## Componentes
- `assets/kaykit/`: personagens e armas do KayKit Adventurers 1.0 (CC0, Kay Lousberg; `LICENSE.txt` na pasta). Os três personagens usam o mesmo rig e as mesmas 76 animações; as armas ficam em nós de encaixe dos ossos das mãos (`handslot_l`, `handslot_r`, importados como `BoneAttachment3D`).
- `components/visual/character_animator.gd` (`CharacterAnimator`): a cada quadro monta um `AnimationState` dos componentes, escolhe o clipe com `AnimationRules` e toca no `AnimationPlayer` do modelo, com transição.
- `components/visual/animation_rules.gd` (`AnimationRules`): regras puras de escolha do clipe e da velocidade de reprodução.
- `components/visual/animation_set.gd` (`AnimationSet`): nomes dos clipes de cada situação e referências de velocidade; um `.tres` por personagem.
- `components/visual/model_loadout.gd` (`ModelLoadout`): esconde os acessórios das mãos que não são usados, prende uma arma extra a um encaixe e troca de conjunto em certos estados da IA.
- `components/visual/combat_visual.gd` (`CombatVisual`): avisos de leitura de jogo (cor no preparo e na vulnerabilidade, arco do golpe).

## Regras
- **Prioridade do clipe:** morte → atordoado → golpe → puxar o tiro → tiro recém-solto → guarda (defesa, se acabou de defender; senão erguida) → locomoção.
- **Locomoção** pela velocidade em relação à frente: parado abaixo de `idle_speed`; de costas quando o movimento para trás predomina; de lado (correndo de lado) quando o lateral predomina; para a frente, correr a partir de `run_threshold`, senão andar.
- **Velocidade de reprodução:** o golpe é esticado ou comprimido para durar o mesmo que o ataque (`AttackData.get_duration()`), e a puxada, o mesmo que `draw_time`; a locomoção acompanha a velocidade real (`walk_reference_speed`, `run_reference_speed`).
- Um ataque novo recomeça o clipe de golpe; um golpe recebido recomeça o de atordoado (o combo se vê); um golpe defendido mostra o clipe de defesa enquanto a guarda segue erguida.
- Os clipes de locomoção e de guarda são marcados como repetidos ao iniciar (o glTF não traz essa marcação).
- Animação de corpo inteiro: andar com o escudo erguido toca só a guarda (as pernas não andam). Misturar parte de cima e de baixo exige `AnimationTree` com filtro de ossos.

## Sinais
Escutados pelo `CharacterAnimator`: `MeleeAttackComponent.attack_started`, `HurtBox.hit_received`, `GuardComponent.blocked`. Pelo `ModelLoadout`: `StateMachine.state_changed`.

## Testes
- `test/unit/animation_rules_test.gd`: prioridade, locomoção por direção e velocidade, ajuste de duração.
