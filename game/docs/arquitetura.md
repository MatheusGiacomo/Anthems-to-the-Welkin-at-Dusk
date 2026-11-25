# Arquitetura

Visão do projeto como ele está **agora**. Atualize no mesmo passo de qualquer mudança nos itens abaixo.

## Visão geral
- Jogo 3D low poly com câmera fixa de cima (ortográfica, inclinada), ambientado na Europa medieval da literatura. Combate hack'n slash: andar com WASD (o player olha para onde anda), atacar e bloquear (com parry) com os botões do mouse.
- O escopo chega em versões do MVP. **MVP V1 (atual): combate e jogabilidade** numa arena plana e fechada, sem props: movimento, ataque, escudo com parry, combo e vulnerabilidade do player; dois inimigos (capanga corpo a corpo e ladrão arqueiro) com spawn e IA; vida para todos, com reinício da arena quando o player morre.
- Todo número de balanceamento é fictício e fica em `Resource` (`.tres`) ou `@export`, editável no inspetor.

## Organização de pastas
Organização por feature: cada cena fica junto do seu script e dos recursos exclusivos dela.

```
<feature>/          ex.: player/, enemies/, ui/hud/
  <nome>.tscn
  <nome>.gd
components/         componentes reutilizados por mais de uma feature (ex.: health_component)
assets/             arte, áudio e fontes compartilhados (assets/kaykit: personagens e armas, CC0)
autoload/           singletons (cada um com decisão registrada)
test/unit/          testes de regras puras
test/scenes/        testes de cena (gdUnit4 scene runner)
```

## Cenas principais
- `arena/arena.tscn` (**Main Scene**) → `Arena` (Node3D, `arena.gd`) → `WorldEnvironment` e `Sun` (luz); `Floor` (StaticBody3D 40×40 m, topo em y = 0); `Walls` (4 StaticBody3D nas bordas); `Player`; `FixedCamera` (enquadra os 40×40 m de `view_bounds`); `Encounter` com cinco `SpawnPoint` (três capangas, dois ladrões); `DebugOverlay`. O `arena.gd` entrega a câmera ao player, dá o player como alvo do encontro e ao painel de debug, spawna os inimigos, trata o F5 e reinicia a arena quando o player morre.
- `enemies/henchman/henchman.tscn` e `enemies/thief/thief.tscn` → `Enemy` (CharacterBody3D flutuante, `enemy.gd`) → os mesmos componentes do player, inclusive o `Knockback` (o ataque é `Sword` ou `Dagger`), `CombatVisual`, `DebugLabel` e `Brain` (`HenchmanBrain` ou `ThiefBrain`) com os estados como filhos. O `Visual` tem o modelo KayKit (`Barbarian` com a espada avulsa, ou `Rogue` com besta e faca), e há também `Animator` e `Loadout`. O ladrão tem ainda `Muzzle` (saída da flecha).
- `enemies/projectiles/arrow.tscn` → `Arrow` (Node3D, `arrow.gd`) → `Model` (flecha do KayKit, girada para apontar em -Z); filha do `Encounter` depois do disparo.
- `player/player.tscn` → `Player` (CharacterBody3D flutuante, `player.gd`) → `CollisionShape3D`, `Visual` (modelo `Knight` do KayKit, escala 0,8 e girado 180°, e o arco do golpe), `Locomotion`, `Health`, `Vulnerability`, `Guard`, `Sword` (MeleeAttackComponent), `HitBox`, `HurtBox`, `CombatVisual`, `Animator` (CharacterAnimator), `Loadout` (ModelLoadout: espada e escudo redondo) e `Knockback` (KnockbackComponent).
- `camera/fixed_camera.tscn` → `FixedCamera` (Camera3D ortográfica parada, `fixed_camera.gd`): enquadra a área que a cena pede e refaz o zoom quando a janela muda.
- `ui/debug/debug_overlay.tscn` → `DebugOverlay` (CanvasLayer, `debug_overlay.gd`) → `Panel/Text` (`%Text`): vida, vulnerabilidade, escudo e ataque do player e inimigos vivos. Cada inimigo tem um `DebugLabel` (Label3D, `enemy_debug_label.gd`) com estado da IA, vida e medidor. F3 liga e desliga os dois.

## Janela
Base de 1920×1080, aberta maximizada (`window/size/mode` = 2) e redimensionável. O 2D estica com a janela (`canvas_items`, `expand`); a `FixedCamera` refaz o zoom do 3D a cada mudança de tamanho. Rodando de dentro do editor com o jogo embutido na aba Game, o tamanho é o da aba.

## Autoloads
_Nenhum._

## Sinais entre sistemas
Formato: `emissor.sinal` → `receptor._handler` — propósito. Sinais internos de cada sistema estão nas notas de `docs/sistemas/`.
- `Player.died` → `Arena._on_player_died` — acalma os inimigos e recarrega a arena após `restart_delay`.
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

O olhar segue a direção do movimento e trava durante o ataque e com o escudo erguido (não é uma ação).

## Camadas de colisão (3D)
| Nº | Nome | Quem está nela | Quem detecta |
|---|---|---|---|
| 1 | `world` | Chão e bordas da arena | Corpos do player e dos inimigos; raio da flecha |
| 2 | `player` | Corpo do player | Corpos dos inimigos |
| 3 | `enemies` | Corpos dos inimigos | Player e os outros inimigos |
| 4 | `player_hurtbox` | HurtBox do player | HitBox dos inimigos; raio da flecha |
| 5 | `enemy_hurtbox` | HurtBox dos inimigos | HitBox do player |
