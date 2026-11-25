# Combate

## Propósito
Resolver golpes entre entidades (player e inimigos) com as mesmas regras: dano, vulnerabilidade
(combo), escudo com parry e choque de espadas. Decisão 0015.

## Componentes
Regras puras (`RefCounted`, testáveis sem cena) envoltas por componentes-nó finos, em `components/`:

| Regra pura | Componente | Papel |
|---|---|---|
| — | `health/HealthComponent` | Vida; `damaged` e `died` |
| `vulnerability/VulnerabilityModel` | `vulnerability/VulnerabilityComponent` | Medidor e estado vulnerável; config em `VulnerabilityConfig` |
| `guard/GuardModel` | `guard/GuardComponent` | Escudo: vida, quebra, recarga, tempos, parry; config em `GuardConfig` |
| `melee_attack/AttackCycle` | `melee_attack/MeleeAttackComponent` | Fases do ataque e intervalo; liga a HitBox só na fase de golpe |
| `hit/HitResolver`, `hit/CombatGeometry` | `hit/HurtBox`, `hit/HitBox` | Resultado do golpe e onde cada efeito é aplicado |
| `knockback/KnockbackRules` | `knockback/KnockbackComponent` | Empurrão de quem é atingido; o movimento fica com `LocomotionComponent.push` |

Dados: `AttackData` (efeitos, defesa possível, fases e ritmo) e os `*Config`, todos `Resource` editáveis no inspetor.

## Regras
- **Vulnerável = atordoado.** Quem está nele não age, toma golpes normalmente e cada golpe com pontos renova a duração (combo). Entrar no estado cancela o ataque e baixa o escudo (responsabilidade do dono, ao ouvir `vulnerable_started`).
- **Medidor:** golpes somam `vulnerability_points`; chegar a `threshold` deixa vulnerável por `duration`. Fora do estado, o medidor esvazia a `decay_rate` depois de `decay_delay` sem ser atingido. Ao sair do estado, volta a 0.
- **Atordoamento direto** (sem encher o medidor), com duração da config de quem é atordoado: `parried_duration` (o próprio golpe foi aparado), `reflected_duration` (bateu na guarda do capanga), `clash_duration` (choque).
- **Resultado de um golpe** (`HitResolver.resolve`), nesta ordem:
  1. `CLASHED`: o defensor está na fase de golpe, de frente (arco de 120°) para o atacante, e o ataque pode trombar. Os dois ficam atordoados.
  2. Se o ataque é defensável, o escudo está erguido e o atacante está no arco dele (`arc_degrees`): `REFLECTED` (guarda que reflete), `PARRIED` (janela de parry e ataque aparável), `GUARD_BROKEN` (a vida do escudo zera) ou `BLOCKED`.
  3. Senão, `HIT`: tira `damage` da vida e soma `vulnerability_points`.
- **Escudo:** cada defesa tira `guard_damage` da vida dele (flecha 35 = três flechas; corpo a corpo 100 = quebra na hora). Quebrado, só ergue de novo após `broken_lockout`; abaixado por vontade ou interrupção, após `release_lockout`. Abaixado, recarrega na taxa `max_health / full_regen_time`. Parry perfeito: golpe defendido até `perfect_window` segundos depois de erguer; flechas nunca são aparadas.
- **Ataque:** fases `windup` → `active` → `recovery`; o próximo ataque só começa `get_cooldown()` segundos depois do início do anterior (o maior entre a duração e `1 / attacks_per_second`). A HitBox acerta cada HurtBox uma vez por golpe.
- **Onde cada efeito é aplicado:** a HurtBox aplica no defensor (dano, pontos, desgaste do escudo, atordoamento no choque); a HitBox aplica no atacante (atordoamento por parry, guarda refletida e choque), a partir do resultado que a HurtBox devolve.
- Quem já morreu ignora golpes (`IGNORED`).
- **Empurrão (knockback):** o atingido é empurrado na direção em que o golpe viaja por `knockback_distance` do ataque × fração do resultado × `resistance` da entidade. Fração: 1 no `HIT`; `blocked_scale` (0,5) quando o escudo defende (`BLOCKED`, `GUARD_BROKEN`, `REFLECTED`); 0 no parry e no choque. A velocidade começa em `2 × distância / duration` e cai linearmente até zero em `duration` (0,15 s); nesse tempo a entidade não controla o movimento. Flechas não empurram (`knockback_distance` 0).

### Player (`player/player.gd`)
- **Atacar** (`attack`): golpe para a frente (`sword_slash.tres`: 1,25 ataque/s, um a cada 0,8 s), só com o escudo abaixado. O olhar trava durante o ataque (`lock_facing_while_attacking`) e a velocidade cai para `attacking_multiplier`.
- **Bloquear** (`block`, segurar): ergue o escudo (`player_guard.tres`) fora de um ataque; a velocidade cai para `blocking_multiplier` e não dá para atacar. Soltar o botão abaixa.
- **Ao abaixar o escudo**, por qualquer motivo, o intervalo do ataque recomeça inteiro; depois de um parry perfeito, recomeça em `perfect_parry_cooldown_scale` (metade).
- Depois de o escudo **quebrar ou ser interrompido**, só ergue de novo com um novo clique (segurar não reergue sozinho), para o parry perfeito não acontecer sem intenção.
- **Vulnerável** (`player_vulnerability.tres`, 0,6 s): não age; o ataque é cancelado e o escudo abaixado.
- **Morte**: para de lutar, a HurtBox deixa de receber golpes e o player emite `died`; a `LevelSequence` acalma os inimigos e recarrega a fase depois de `restart_delay` (1 s; na arena de teste, 1,5 s).
- Visual provisório (`CombatVisual`): escudo visível quando erguido, arco branco na fase de golpe, corpo laranja no preparo, amarelo quando vulnerável e cinza morto (o mesmo para os inimigos).

## Sinais
- `HealthComponent.damaged(amount, remaining)`, `died`.
- `VulnerabilityComponent.vulnerable_started`, `vulnerable_ended`.
- `GuardComponent.raised`, `lowered(reason, after_perfect_parry)`, `blocked(perfect, broke)`.
- `MeleeAttackComponent.attack_started`, `phase_changed(phase)`, `attack_finished(completed)`.
- `HurtBox.hit_received(hit, outcome)`: o inimigo usa para ficar agressivo contra quem bateu.
- `HitBox.hit_resolved(hurt_box, outcome)`: a investida usa para decidir o passo seguinte.

## Testes
`test/unit/`: `vulnerability_model_test`, `health_component_test`, `guard_model_test`,
`attack_cycle_test`, `hit_resolver_test`, `combat_geometry_test`, `knockback_rules_test` e
`hurt_box_test` (componentes reais, sem física).
`test/scenes/knockback_test.gd`: o golpe do player afasta o capanga atingido.
`test/unit/balance_invariants_test.gd`: lê os `.tres` e garante as duas restrições do MVP — um
único inimigo (corpo a corpo ou arqueiro) não consegue combar o player, e o combo do player
encadeia em todo inimigo. Ajuste de números que quebre uma delas reprova o check.

## Onde ajustar os números
| O quê | Arquivo | Campos |
|---|---|---|
| Ataque do player | `player/sword_slash.tres` | `attacks_per_second` (1,25 = um a cada 0,8 s), `windup`, `active`, `recovery`, `damage`, `vulnerability_points`, `knockback_distance` |
| Movimento do player | `player/player_config.tres` | `move_speed`, `blocking_multiplier`, `attacking_multiplier`, travas do olhar, `perfect_parry_cooldown_scale` |
| Escudo do player | `player/player_guard.tres` | `max_health`, `perfect_window` (parry), `full_regen_time`, `broken_lockout`, `release_lockout`, `arc_degrees` |
| Vulnerabilidade (combo) | `player/player_vulnerability.tres`, `enemies/<inimigo>/<inimigo>_vulnerability.tres` | `threshold`, `duration`, `parried_duration`, `reflected_duration`, `clash_duration` |
| Tempo da cautela até a investida | `enemies/henchman/henchman_behavior.tres`, `enemies/thief/thief_melee.tres` | `time_to_lunge`, `reflect_lunge_delay` |
| Distâncias e velocidades da IA corpo a corpo | os mesmos dois | `approach_distance` (X), `caution_distance` (Y), `caution_tolerance`, `run_speed`, `caution_speed`, `strafe_speed`, `strike_reach`, `max_lunge_distance` |
| Golpe da investida | `enemies/henchman/henchman_sword.tres`, `enemies/thief/thief_dagger.tres` | `windup` (preparo visível), `active`, `recovery`, `damage`, `knockback_distance` |
| Tiro do ladrão | `enemies/thief/thief_ranged.tres`, `enemies/thief/thief_arrow.tres` | `draw_time`, `reload_time`, `arrow_speed`, `attack_distance`, `fight_chance`; dano e desgaste no `thief_arrow.tres` |
| Vida | nó `Health` em `player/player.tscn`, `enemies/henchman/henchman.tscn`, `enemies/thief/thief.tscn` | `max_health` |
| Reação ao empurrão | nó `Knockback` nas mesmas cenas | `duration`, `resistance`, `blocked_scale` |

O `test/unit/balance_invariants_test.gd` reprova ajustes que deixam um inimigo "combar" o player ou que quebram o combo do player.
