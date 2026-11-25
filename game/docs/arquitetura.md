# Arquitetura

Visão do projeto como ele está **agora**. Atualize no mesmo passo de qualquer mudança nos itens abaixo.

## Visão geral
- Jogo 3D low poly com câmera isométrica, ambientado na Europa medieval da literatura. Combate hack'n slash: andar com WASD, olhar com o mouse, atacar e bloquear (com parry).
- O escopo chega em versões do MVP. **MVP V1 (atual): combate e jogabilidade** numa arena plana e fechada, sem props: movimento, ataque, escudo com parry, combo e vulnerabilidade do player; dois inimigos (capanga corpo a corpo e ladrão arqueiro) com spawn e IA; vida para todos, com reinício da arena quando o player morre.
- Todo número de balanceamento é fictício e fica em `Resource` (`.tres`) ou `@export`, editável no inspetor.

## Organização de pastas
Organização por feature: cada cena fica junto do seu script e dos recursos exclusivos dela.

```
<feature>/          ex.: player/, enemies/, ui/hud/
  <nome>.tscn
  <nome>.gd
components/         componentes reutilizados por mais de uma feature (ex.: health_component)
assets/             arte, áudio e fontes compartilhados
autoload/           singletons (cada um com decisão registrada)
test/unit/          testes de regras puras
test/scenes/        testes de cena (gdUnit4 scene runner)
```

## Cenas principais
- `arena/arena.tscn` (**Main Scene**) → `Arena` (Node3D, `arena.gd`) → `WorldEnvironment` e `Sun` (luz); `Floor` (StaticBody3D 40×40 m, topo em y = 0); `Walls` (4 StaticBody3D nas bordas); `Player`; `IsometricCamera` (alvo: `Player`); `Encounter` com cinco `SpawnPoint` (três capangas, dois ladrões). O `arena.gd` entrega a câmera ao player, dá o player como alvo do encontro, spawna os inimigos e trata o F5.
- `enemies/henchman/henchman.tscn` e `enemies/thief/thief.tscn` → `Enemy` (CharacterBody3D flutuante, `enemy.gd`) → os mesmos componentes do player (o ataque é `Sword` ou `Dagger`), `CombatVisual` e `Brain` (`HenchmanBrain` ou `ThiefBrain`) com os estados como filhos. O ladrão tem ainda `Muzzle` (saída da flecha) e o arco puxado em `Visual/BowDrawn`.
- `enemies/projectiles/arrow.tscn` → `Arrow` (Node3D, `arrow.gd`), filha do `Encounter` depois do disparo.
- `player/player.tscn` → `Player` (CharacterBody3D flutuante, `player.gd`) → `CollisionShape3D`, `Visual` (cápsula, "nariz" que mostra a frente, escudo e arco do golpe), `Locomotion`, `Health`, `Vulnerability`, `Guard`, `Sword` (MeleeAttackComponent), `HitBox`, `HurtBox`, `CombatVisual`.
- `camera/isometric_camera.tscn` → `IsometricCamera` (Camera3D ortográfica, `isometric_camera.gd`).

## Autoloads
_Nenhum._

## Sinais entre sistemas
Formato: `emissor.sinal` → `receptor._handler` — propósito. Sinais internos de cada sistema estão nas notas de `docs/sistemas/`.
- `Enemy.died` → `Encounter._on_enemy_died` — contagem de vivos.
- `HurtBox.hit_received` → `Enemy._on_hurt_box_hit_received` — inimigo atingido fora de combate fica agressivo contra quem bateu.

## Input map
| Ação | Entrada | Uso |
|---|---|---|
| `move_forward`, `move_back`, `move_left`, `move_right` | W, S, A, D (teclas físicas) | Movimento relativo à câmera (W = para cima na tela) |
| `attack` | Botão esquerdo do mouse | Golpe na direção em que o player olha |
| `block` | Botão direito do mouse (segurar) | Erguer o escudo |
| `debug_toggle_overlay` | F3 | Mostra/esconde o painel de balanceamento |
| `debug_respawn_enemies` | F5 | Remove os inimigos e spawna de novo |

O olhar segue o cursor projetado no chão (não é uma ação).

## Camadas de colisão (3D)
| Nº | Nome | Quem está nela | Quem detecta |
|---|---|---|---|
| 1 | `world` | Chão e bordas da arena | Corpos do player e dos inimigos; raio da flecha |
| 2 | `player` | Corpo do player | Corpos dos inimigos |
| 3 | `enemies` | Corpos dos inimigos | Player e os outros inimigos |
| 4 | `player_hurtbox` | HurtBox do player | HitBox dos inimigos; raio da flecha |
| 5 | `enemy_hurtbox` | HurtBox dos inimigos | HitBox do player |
