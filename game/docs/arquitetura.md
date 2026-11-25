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
_Nenhuma ainda. Formato: cena → nó raiz (tipo) → filhos relevantes e propósito._

## Autoloads
_Nenhum._

## Sinais entre sistemas
_Nenhum. Formato: `emissor.sinal` → `receptor._handler` — propósito._

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
