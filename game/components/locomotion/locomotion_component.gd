class_name LocomotionComponent
extends Node
## Move e gira um CharacterBody3D no chão: acelera até a velocidade pedida e gira até a direção
## pedida, limitado por `turn_speed_degrees`. Também aplica empurrões (`push`), durante os quais a
## velocidade pedida é ignorada. Usado pelo player e pelos inimigos.

# Abaixo disso, a direção pedida é considerada nula.
const MIN_DIRECTION_SQUARED: float = 0.0001

@export var body: CharacterBody3D
## Metros por segundo² para chegar à velocidade pedida (vale para acelerar e frear).
@export var acceleration: float = 40.0
## Graus por segundo de giro (0 = gira na hora).
@export var turn_speed_degrees: float = 900.0

# Empurrão em curso: velocidade inicial (com a direção), tempo decorrido e duração total.
var _push_velocity: Vector3 = Vector3.ZERO
var _push_elapsed: float = 0.0
var _push_duration: float = 0.0


## Avisa se o corpo não foi atribuído.
func _ready() -> void:
	if body == null:
		push_warning("%s: LocomotionComponent sem body." % get_path())


## Leva a velocidade horizontal do corpo até `desired_velocity`, limitada por `acceleration`, e
## move com colisão. Chame uma vez por quadro de física; `Vector3.ZERO` freia até parar. Durante
## um empurrão, ignora `desired_velocity` e move com a velocidade do empurrão.
func move(desired_velocity: Vector3, delta: float) -> void:
	if is_pushed():
		_move_pushed(delta)
		return
	var target: Vector3 = CombatGeometry.flatten(desired_velocity)
	body.velocity = body.velocity.move_toward(target, acceleration * delta)
	body.move_and_slide()


## Empurra o corpo com `push_velocity` (no chão), caindo linearmente até zero em `duration`
## segundos. Um empurrão novo substitui o anterior.
func push(push_velocity: Vector3, duration: float) -> void:
	_push_velocity = CombatGeometry.flatten(push_velocity)
	_push_elapsed = 0.0
	_push_duration = duration


## Devolve se há um empurrão em curso.
func is_pushed() -> bool:
	return _push_elapsed < _push_duration


## Gira o corpo em direção a `direction` (no chão), no máximo `turn_speed_degrees` por segundo.
## Ignora direção nula.
func face_direction(direction: Vector3, delta: float) -> void:
	var flat: Vector3 = CombatGeometry.flatten(direction)
	if flat.length_squared() < MIN_DIRECTION_SQUARED:
		return
	var target_yaw: float = CombatGeometry.yaw_for_direction(flat.normalized())
	if turn_speed_degrees <= 0.0:
		body.rotation.y = target_yaw
		return
	var max_step: float = deg_to_rad(turn_speed_degrees) * delta
	body.rotation.y = rotate_toward(body.rotation.y, target_yaw, max_step)


## Vira o corpo na hora para `direction` (no chão). Ignora direção nula.
func snap_to_direction(direction: Vector3) -> void:
	var flat: Vector3 = CombatGeometry.flatten(direction)
	if flat.length_squared() < MIN_DIRECTION_SQUARED:
		return
	body.rotation.y = CombatGeometry.yaw_for_direction(flat.normalized())


## Devolve a frente do corpo no chão, normalizada.
func get_forward() -> Vector3:
	return CombatGeometry.forward_of(body)


## Move um quadro do empurrão. A velocidade é a do meio do quadro, para o trecho percorrido somar
## a distância do empurrão.
func _move_pushed(delta: float) -> void:
	var start_speed: float = _push_velocity.length()
	var speed: float = KnockbackRules.speed_at(
		start_speed, _push_elapsed + delta * 0.5, _push_duration
	)
	body.velocity = _push_velocity.normalized() * speed
	_push_elapsed += delta
	body.move_and_slide()
