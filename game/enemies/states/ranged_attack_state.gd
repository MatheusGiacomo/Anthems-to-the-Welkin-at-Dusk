class_name RangedAttackState
extends EnemyState
## Tiro com arco: olha para o alvo e mira, avançando devagar enquanto o alvo está além de
## X − tolerância. Depois de `reload_time`, para e puxa o arco por `draw_time` segundos e solta
## uma flecha balística na posição do alvo naquele instante. Não termina sozinho.

enum Phase { AIMING, DRAWING }

@export var behavior: RangedBehaviorConfig
@export var arrow_scene: PackedScene
## Ponto de onde a flecha sai.
@export var muzzle: Node3D
## Opcional: mostrado enquanto o arco está puxado (o aviso do tiro).
@export var draw_indicator: Node3D

var _phase: Phase = Phase.AIMING
var _timer: float = 0.0
var _since_shot: float = INF


## Começa mirando; o primeiro tiro espera `reload_time`.
func enter() -> void:
	_set_phase(Phase.AIMING, behavior.reload_time)


## Esconde o aviso do tiro (o tiro em preparo é perdido) e esquece o último disparo.
func exit() -> void:
	_set_phase(Phase.AIMING, behavior.reload_time)
	_since_shot = INF


## Olha para o alvo; mirando, avança ou fica parado e conta o tempo até puxar; puxando, fica
## parado e solta a flecha ao fim de `draw_time`. Conta também o tempo desde o último disparo.
func physics_update(delta: float) -> void:
	_since_shot += delta
	var to_target: Vector3 = context.direction_to_target()
	context.locomotion.face_direction(to_target, delta)
	var velocity: Vector3 = Vector3.ZERO
	var advances: bool = ThiefRules.advances_while_aiming(context.distance_to_target(), behavior)
	if _phase == Phase.AIMING and advances:
		velocity = to_target * behavior.walk_speed
	context.locomotion.move(velocity, delta)
	_timer -= delta
	if _timer > 0.0:
		return
	if _phase == Phase.AIMING:
		_set_phase(Phase.DRAWING, behavior.draw_time)
	else:
		_shoot()
		_set_phase(Phase.AIMING, behavior.reload_time)


## Devolve se a arma está sendo puxada (a fase antes do disparo).
func is_drawing() -> bool:
	return _phase == Phase.DRAWING


## Devolve os segundos desde o último disparo neste estado (`INF` se não houve).
func get_seconds_since_shot() -> float:
	return _since_shot


## Troca de fase, reinicia o tempo dela e mostra o aviso só enquanto o arco está puxado.
func _set_phase(phase: Phase, duration: float) -> void:
	_phase = phase
	_timer = duration
	if draw_indicator != null:
		draw_indicator.visible = phase == Phase.DRAWING


## Solta uma flecha do `muzzle` mirada na posição atual do alvo, no nó de projéteis do contexto
## (ou ao lado do inimigo, se não houver), e zera o tempo desde o disparo.
func _shoot() -> void:
	if not context.has_target():
		return
	_since_shot = 0.0
	var arrow: Arrow = arrow_scene.instantiate() as Arrow
	var parent: Node = context.projectile_parent
	if parent == null or not is_instance_valid(parent):
		parent = context.body.get_parent()
	parent.add_child(arrow)
	arrow.global_position = muzzle.global_position
	var aim_point: Vector3 = context.target.global_position + Vector3.UP * behavior.aim_height
	var velocity: Vector3 = Ballistics.launch_velocity(
		muzzle.global_position, aim_point, behavior.arrow_speed, behavior.arrow_gravity
	)
	arrow.launch(velocity, behavior.arrow_gravity, behavior.arrow_attack, context.body)
