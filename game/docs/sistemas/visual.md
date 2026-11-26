# Visual

## Propósito
Mostrar o combate com personagens animados, sem mudar regra de jogo: o visual só lê o estado dos
componentes.

## Componentes
- `assets/kaykit/`: personagens e armas do KayKit Adventurers 1.0 (CC0, Kay Lousberg; `LICENSE.txt` na pasta). Os três personagens usam o mesmo rig e as mesmas 76 animações; as armas ficam em nós de encaixe dos ossos das mãos (`handslot_l`, `handslot_r`, importados como `BoneAttachment3D`).
- `components/visual/character_animator.gd` (`CharacterAnimator`): a cada quadro monta um `AnimationState` dos componentes, escolhe os clipes com `AnimationRules` e os toca numa `AnimationTree` de duas camadas que ele mesmo monta em código, como filha (decisão 0018). O `AnimationPlayer` do modelo fica só como biblioteca de clipes.
- `components/visual/skeleton_regions.gd` (`SkeletonRegions`): regra pura dos ossos de um ramo do esqueleto (o osso e os descendentes).
- `components/visual/animation_rules.gd` (`AnimationRules`): regras puras de escolha do clipe e da velocidade de reprodução.
- `components/visual/animation_set.gd` (`AnimationSet`): nomes dos clipes de cada situação, referências de velocidade e o osso onde começa a parte de cima (`upper_body_root`, `spine`); um `.tres` por personagem.
- `components/visual/model_loadout.gd` (`ModelLoadout`): esconde os acessórios das mãos que não são usados, prende uma arma extra a um encaixe e troca de conjunto em certos estados da IA.
- `components/visual/combat_visual.gd` (`CombatVisual`): avisos de leitura de jogo (cor no preparo e na vulnerabilidade, arco do golpe).

## Personagens
| Entidade | Modelo | Nas mãos (`ModelLoadout`) | Clipes próprios (`*_animations.tres`) |
|---|---|---|---|
| Player | `Knight` | `1H_Sword`, `Round_Shield` | golpe `1H_Melee_Attack_Slice_Diagonal`, guarda `Blocking`, andar `Walking_A`, correr `Running_A` |
| Capanga | `Barbarian` | espada avulsa (`sword_1handed.gltf`) no `handslot_r` | golpe `1H_Melee_Attack_Chop`, guarda `2H_Melee_Idle` (espada atravessada à frente), andar `Walking_B` |
| Ladrão | `Rogue` | `2H_Crossbow`; `Knife` nos estados `MeleeChase`, `Caution` e `Lunge` | golpe `1H_Melee_Attack_Stab`, guarda `2H_Melee_Idle`, mira `2H_Ranged_Aiming`, tiro `2H_Ranged_Shoot`, correr `Running_B` |

Comuns: `Idle`, `Walking_Backwards`, `Running_Strafe_Left/Right`, `Block_Hit` (defesa), `Hit_A` (atordoado), `Death_A`. Os modelos têm cerca de 2,4 m (proporção chibi); na cena ficam com escala 0,8 e girados 180° (o glTF olha para +Z; o jogo, para -Z). O ladrão usa besta no lugar do arco: o arco só existe no KayKit Adventurers 2.0 (itch.io).

## Regras
- **Camadas:** a de baixo toca o corpo inteiro; a de cima toca a guarda só em `upper_body_root` e nos ossos abaixo dele (tronco, braços, cabeça), com peso de 0 a 1 que sobe e desce em `blend_time`. O quadril e as pernas ficam sempre com a camada de baixo.
- **Camada de baixo, por prioridade:** morte → atordoado → golpe → puxar o tiro → tiro recém-solto → locomoção. Com a guarda erguida e parado, a guarda (defesa, se acabou de defender; senão erguida) no lugar da locomoção.
- **Camada de cima:** ligada com a guarda erguida quando nada de prioridade maior (morte, atordoado, golpe, puxada, tiro) está ativo. Assim, andar, recuar ou circular com a guarda move as pernas (capanga e ladrão na cautela, player com o escudo).
- **Locomoção** pela velocidade em relação à frente: parado abaixo de `idle_speed`; de costas quando o movimento para trás predomina; de lado (correndo de lado) quando o lateral predomina; para a frente, correr a partir de `run_threshold`, senão andar.
- **Velocidade de reprodução:** o golpe é esticado ou comprimido para durar o mesmo que o ataque (`AttackData.get_duration()`), e a puxada, o mesmo que `draw_time`; a locomoção acompanha a velocidade real (`walk_reference_speed`, `run_reference_speed`).
- Um ataque novo recomeça o clipe de golpe; um golpe recebido recomeça o de atordoado (o combo se vê); um golpe defendido mostra o clipe de defesa pela duração dele e depois volta à guarda erguida.
- Os clipes de locomoção e de guarda são marcados como repetidos ao iniciar (o glTF não traz essa marcação).
- A velocidade de reprodução vale só para a camada de baixo; a guarda de cima toca na velocidade normal.
- O preparo da investida ainda é de corpo inteiro: o inimigo avança com o clipe de golpe, sem passos.

## Sinais
Escutados pelo `CharacterAnimator`: `MeleeAttackComponent.attack_started`, `HurtBox.hit_received`, `GuardComponent.blocked`. Pelo `ModelLoadout`: `StateMachine.state_changed`.

## Testes
- `test/unit/animation_rules_test.gd`: prioridade, guarda em camada sobre a locomoção, locomoção por direção e velocidade, ajuste de duração.
- `test/unit/skeleton_regions_test.gd`: ramo do esqueleto.
- `test/scenes/guard_layer_animation_test.gd`: capanga na cautela anda com a locomoção embaixo e a guarda em cima.
