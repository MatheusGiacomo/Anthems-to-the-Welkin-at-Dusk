# Inimigos

## Propósito
IA de combate dos inimigos, montada com estados reutilizáveis e um cérebro por inimigo
(decisão 0016).

## Componentes
- `enemies/enemy.gd` (`Enemy`): base de todo inimigo. `spawn(transform)` coloca parado e sem alvo; `aggro(target)` dá o alvo e liga a IA; `calm()` larga o alvo. Fora de combate, quem bate vira o alvo. Ao morrer, emite `died(enemy)` e sai da cena.
- `enemies/enemy_brain.gd` (`EnemyBrain`): máquina de estados com alvo, vulnerabilidade e contexto (`AgentContext`). Subclasses decidem o combate em `_start_combat`, `_update_combat` e `_resume_after_stagger`.
- `enemies/agent_context.gd` (`AgentContext`): corpo, movimento, alvo e onde adicionar projéteis.
- `components/state_machine/` (`StateMachine`, `State`): máquina genérica.
- `enemies/melee_behavior_config.gd` (`MeleeBehaviorConfig`): valores de um perfil corpo a corpo (distâncias X e Y, velocidades, tempos da cautela, avanço da investida).
- `enemies/melee_behavior_rules.gd` (`MeleeBehaviorRules`): regras puras do combate corpo a corpo.
- `enemies/melee_tactics.gd` (`MeleeTactics`): aplica essas regras a um trio de estados (aproximação, cautela, investida) e devolve o próximo; usado pelo capanga e pelo ladrão com a adaga.
- Estados em `enemies/states/` (`EnemyState`):

| Estado | Comportamento | Termina com |
|---|---|---|
| `IdleState` | Parado, sem alvo | — |
| `ChaseState` | Corre até o alvo olhando para onde corre (aproximação) | — (o cérebro troca pela distância) |
| `CautionState` | Guarda erguida, olha para o alvo, avança até Y, orbita entre Y e Y + tolerância, recua abaixo de Y | `LUNGE_READY` |
| `LungeState` | Sem guarda; avança durante o preparo do ataque e golpeia; guarda o resultado em `result` | `DONE` |
| `StaggeredState` | Vulnerável: não age, só freia | — (o cérebro sai em `vulnerable_ended`) |

## Regras
- Ficar vulnerável interrompe qualquer estado (o `exit` dele cancela ataque e guarda) e leva ao `StaggeredState`; ao sair, o cérebro escolhe o estado pelo tipo de inimigo.
- Agressão durante a vulnerabilidade só começa quando o estado acaba.
- Se o alvo deixa de existir, o inimigo fica parado.
- Movimento sem navmesh: o mapa é plano e sem props, e os inimigos vão em linha reta, colidindo entre si.

### Capanga (`enemies/henchman/`)
Cena `henchman.tscn`, cérebro `HenchmanBrain` (só `MeleeTactics`). Valores: `henchman_behavior.tres`, `henchman_sword.tres`, `henchman_guard.tres`, `henchman_vulnerability.tres`; vida 60 (`@export` do `Health` na cena).
1. **Aproximação** (`Chase`): mais longe que X (`approach_distance`, 6 m), corre (`run_speed`).
2. **Cautela** (`Caution`): a até X, anda devagar com a guarda erguida. Só volta a correr acima de X + `distance_hysteresis`. A guarda é inquebrável e reflete: golpe defendido atordoa o atacante (`reflected_duration` dele) e agenda a investida para `reflect_lunge_delay` (0,5 s) depois. Com o alvo a até Y + `caution_tolerance` por `time_to_lunge` segundos (mais perto também conta), vai para a investida. O sentido em que orbita é sorteado e troca a cada `strafe_flip_min`–`strafe_flip_max` segundos.
3. **Investida** (`Lunge`): `henchman_sword.tres` com preparo 0,8 s (o avanço), golpe 0,6 s (o dano, de 0,8 a 1,4 s) e recuperação 0,6 s (2 s no total). A direção e o avanço (distância − `strike_reach`, até `max_lunge_distance`) são fixados no início. Sem guarda o tempo todo: atingido no preparo ou na recuperação, fica vulnerável e a investida é interrompida; atingido no golpe, de frente, há choque.
- **Depois da investida** (`MeleeBehaviorRules.after_lunge`): acertou o alvo → investida; defendida ou choque → cautela; senão, alvo mais perto que Y → investida, e o resto → cautela. Atingido pelo player → vulnerável e, ao sair, cautela (ou aproximação, se o alvo se afastou).

## Sinais
- `Enemy.died(enemy)` → quem spawnou o inimigo.
- `HurtBox.hit_received` → `Enemy._on_hurt_box_hit_received`: agressão contra quem bateu; → `CautionState`: golpe defendido agenda a investida.
- `HitBox.hit_resolved` → `LungeState`: resultado da investida.
- `MeleeAttackComponent.attack_finished` → `LungeState`: fim da investida.
- `VulnerabilityComponent.vulnerable_started/ended` → `EnemyBrain`.
- `State.finished(reason)` → `StateMachine._on_current_finished`.

## Testes
- `test/unit/state_machine_test.gd`: entrada e saída dos estados e repasse do fim só do estado atual.
- `test/unit/melee_behavior_rules_test.gd`: troca de modo pela distância com folga, tabela pós-investida, saída da vulnerabilidade, movimento na cautela, avanço da investida.
- `test/unit/combat_geometry_test.gd`: a órbita mantém o raio e a velocidade.
- `test/scenes/henchman_ai_test.gd`: agressivo e longe, corre e entra na cautela.
- `test/scenes/player_attack_test.gd`: o golpe do player tira vida e deixa o capanga vulnerável.
- `test/scenes/player_guard_test.gd`: o escudo erguido defende a investida sem perda de vida.
- Montagem comum dos testes de cena: `test/scenes/combat_arena.gd` (`CombatTestArena`).
