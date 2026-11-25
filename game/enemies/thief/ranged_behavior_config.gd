class_name RangedBehaviorConfig
extends Resource
## Valores do combate à distância do ladrão: distância de tiro, ritmo do arco, flecha, fuga e a
## chance de lutar com a adaga quando o player chega perto.

@export_group("Distâncias")
## X: distância de tiro. Mais longe, corre até o alvo; mais perto que isso, conta como "perto".
@export var attack_distance: float = 10.0
## Entre X − este valor e X, avança devagar enquanto mira; mais perto, fica parado.
@export var distance_tolerance: float = 1.5
## Folga para voltar a correr: só acima de X + este valor.
@export var distance_hysteresis: float = 0.5

@export_group("Velocidades")
## Metros por segundo na aproximação.
@export var run_speed: float = 5.0
## Metros por segundo avançando enquanto mira.
@export var walk_speed: float = 1.5
## Metros por segundo na fuga.
@export var flee_speed: float = 5.5

@export_group("Arco")
## Segundos puxando o arco, parado, até soltar a flecha.
@export var draw_time: float = 1.0
## Segundos, depois de soltar (e ao começar a mirar), até puxar o arco de novo.
@export var reload_time: float = 1.0
## Metros por segundo da flecha ao sair do arco.
@export var arrow_speed: float = 18.0
## Gravidade da flecha, em m/s² (0 = linha reta).
@export var arrow_gravity: float = 9.8
## Altura, acima dos pés do alvo, para onde a flecha é mirada.
@export var aim_height: float = 1.0
## Efeitos da flecha (dano, vulnerabilidade, desgaste do escudo).
@export var arrow_attack: AttackData

@export_group("Reação ao ser atingido")
## Chance (0 a 1) de lutar com a adaga, em vez de fugir, ao sair da vulnerabilidade perto do alvo.
@export var fight_chance: float = 0.5
