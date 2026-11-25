# Arquitetura

Visão do projeto como ele está **agora**. Atualize no mesmo passo de qualquer mudança nos itens abaixo.

## Visão geral
- Jogo 3D low poly com câmera fixa de cima (ortográfica, inclinada), ambientado na Europa medieval da literatura. Combate hack'n slash: andar com WASD (o player olha para onde anda), atacar e bloquear (com parry) com os botões do mouse.
- O escopo chega em versões do MVP. **MVP V1 (atual): combate e jogabilidade** em três fases encadeadas com props placeholder (entrar por um lado, vencer os inimigos, sair pelo outro): movimento, ataque, escudo com parry, combo e vulnerabilidade do player; dois inimigos (capanga corpo a corpo e ladrão arqueiro) com spawn e IA; vida para todos, com reinício da fase quando o player morre. A arena plana do início fica como cena de teste.
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
- `levels/level_sequence.tscn` (**Main Scene**) → `LevelSequence` (Node3D, `level_sequence.gd`) → `FixedCamera`, `LevelSlot` (a fase atual fica aqui, com o player como filho dela), `DebugOverlay`, `ScreenFade`. Carrega as fases da lista `levels`, enquadra a câmera, liga o debug, troca de fase com escurecimento e recarrega a fase quando o player morre. Ver `sistemas/fases.md`.
- `levels/level_01.tscn`, `level_02.tscn`, `level_03.tscn` → `Level` (Node3D, `level.gd`) → `WorldEnvironment`, `Sun`, `Ground` (chão 44×24 m e o caminho), `Walls`, `Props` (instâncias de `levels/props/tree.tscn` e `rock.tscn`), `Encounter` com `SpawnPoint`s, `PlayerStart` (Marker3D) e `Exit` (`LevelExit`).
- `levels/level_exit.tscn` → `LevelExit` (Node3D) → `Barrier` (StaticBody3D, camada `world`) e `Trigger` (Area3D, máscara `player`).
- `ui/transition/screen_fade.tscn` → `ScreenFade` (CanvasLayer, camada 10) → `Cover` (ColorRect preto).
- `arena/arena.tscn` (cena de teste) → `Arena` (Node3D, `arena.gd`) → `WorldEnvironment` e `Sun`; `Floor` (40×40 m); `Walls`; `Player`; `FixedCamera` (enquadra os 40×40 m de `view_bounds`); `Encounter` com cinco `SpawnPoint` (três capangas, dois ladrões); `DebugOverlay`. Trata o F5 e reinicia a arena quando o player morre.
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
- `Player.died` → `LevelSequence._on_player_died` — acalma os inimigos e recarrega a fase após `restart_delay` (na arena de teste, `Arena._on_player_died`).
- `Level.exit_reached` → `LevelSequence._on_level_exit_reached` — troca para a próxima fase com escurecimento.
- `Encounter.all_enemies_died` → `Level._on_encounter_all_enemies_died` — abre a saída da fase.
- `Enemy.died` → `Encounter._on_enemy_died` — contagem de vivos.
- `HurtBox.hit_received` → `Enemy._on_hurt_box_hit_received` — inimigo atingido fora de combate fica agressivo contra quem bateu.

## Input map
| Ação | Entrada | Uso |
|---|---|---|
| `move_forward`, `move_back`, `move_left`, `move_right` | W, S, A, D (teclas físicas) | Movimento relativo à câmera (W = para cima na tela) |
| `attack` | Botão esquerdo do mouse | Golpe na direção em que o player olha |
| `block` | Botão direito do mouse (segurar) | Erguer o escudo |
| `debug_toggle_overlay` | F3 | Mostra/esconde o painel de balanceamento |
| `debug_respawn_enemies` | F5 | Remove os inimigos da fase (ou da arena) e spawna de novo |

O olhar segue a direção do movimento e trava durante o ataque e com o escudo erguido (não é uma ação).

## Camadas de colisão (3D)
| Nº | Nome | Quem está nela | Quem detecta |
|---|---|---|---|
| 1 | `world` | Chão, bordas, props e barreira da saída | Corpos do player e dos inimigos; raio da flecha |
| 2 | `player` | Corpo do player | Corpos dos inimigos; área de chegada da saída |
| 3 | `enemies` | Corpos dos inimigos | Player e os outros inimigos |
| 4 | `player_hurtbox` | HurtBox do player | HitBox dos inimigos; raio da flecha |
| 5 | `enemy_hurtbox` | HurtBox dos inimigos | HitBox do player |
