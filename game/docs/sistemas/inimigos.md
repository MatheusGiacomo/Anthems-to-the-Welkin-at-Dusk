# Inimigos

## Propósito
IA de combate dos inimigos, montada com estados reutilizáveis e um cérebro por inimigo
(decisão 0016).

## Componentes
- `enemies/enemy.gd` (`Enemy`): base de todo inimigo. `spawn(transform)` coloca parado e sem alvo; `aggro(target)` dá o alvo e liga a IA; `calm()` larga o alvo. Fora de combate, quem bate vira o alvo. Ao morrer, emite `died(enemy)` e sai da cena.
- `enemies/enemy_brain.gd` (`EnemyBrain`): máquina de estados com alvo, vulnerabilidade e contexto (`AgentContext`). Subclasses decidem o combate em `_start_combat`, `_update_combat` e `_resume_after_stagger`.
- `enemies/agent_context.gd` (`AgentContext`): corpo, movimento, alvo e onde adicionar projéteis.
- `components/state_machine/` (`StateMachine`, `State`): máquina genérica.
- Estados em `enemies/states/` (`EnemyState`):

| Estado | Comportamento |
|---|---|
| `IdleState` | Parado, sem alvo |
| `ChaseState` | Corre até o alvo olhando para onde corre (aproximação) |
| `StaggeredState` | Vulnerável: não age, só freia |

## Regras
- Ficar vulnerável interrompe qualquer estado (o `exit` dele cancela ataque e guarda) e leva ao `StaggeredState`; ao sair, o cérebro escolhe o estado pelo tipo de inimigo.
- Agressão durante a vulnerabilidade só começa quando o estado acaba.
- Se o alvo deixa de existir, o inimigo fica parado.
- Movimento sem navmesh: o mapa é plano e sem props, e os inimigos vão em linha reta, colidindo entre si.

## Sinais
- `Enemy.died(enemy)` → quem spawnou o inimigo.
- `HurtBox.hit_received` → `Enemy._on_hurt_box_hit_received`: agressão contra quem bateu.
- `VulnerabilityComponent.vulnerable_started/ended` → `EnemyBrain`.
- `State.finished(reason)` → `StateMachine._on_current_finished`.

## Testes
- `test/unit/state_machine_test.gd`: entrada e saída dos estados e repasse do fim só do estado atual.
