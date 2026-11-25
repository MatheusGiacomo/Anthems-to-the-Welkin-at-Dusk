class_name MeleeBehaviorConfig
extends Resource
## Valores de um perfil de combate corpo a corpo (aproximação, cautela e investida): o do capanga
## com a espada e o do ladrão com a adaga.

@export_group("Distâncias")
## X: mais longe que isso, o inimigo corre até o alvo (aproximação); mais perto, fica em cautela.
@export var approach_distance: float = 6.0
## Folga para sair da cautela: volta a correr só acima de `approach_distance` + este valor.
@export var distance_hysteresis: float = 0.5
## Y: na cautela, o inimigo chega só até esta distância e então circula o alvo.
@export var caution_distance: float = 2.5
## "Um pouco mais que Y": entre Y e Y + este valor, o inimigo circula e conta o tempo da investida.
@export var caution_tolerance: float = 0.75

@export_group("Velocidades")
## Metros por segundo na aproximação.
@export var run_speed: float = 5.5
## Metros por segundo avançando ou recuando na cautela.
@export var caution_speed: float = 1.8
## Metros por segundo circulando o alvo na cautela.
@export var strafe_speed: float = 1.5

@export_group("Cautela")
## Segundos perto do alvo (até Y + tolerância) até a investida.
@export var time_to_lunge: float = 1.5
## Menor intervalo, em segundos, para trocar o sentido em que circula.
@export var strafe_flip_min: float = 2.0
## Maior intervalo, em segundos, para trocar o sentido em que circula.
@export var strafe_flip_max: float = 4.0
## Segundos entre defender um golpe (atordoando o atacante) e a investida.
@export var reflect_lunge_delay: float = 0.5

@export_group("Investida")
## Distância do alvo em que o avanço da investida para (o alcance do golpe).
@export var strike_reach: float = 1.4
## Maior avanço da investida, em metros.
@export var max_lunge_distance: float = 4.0
