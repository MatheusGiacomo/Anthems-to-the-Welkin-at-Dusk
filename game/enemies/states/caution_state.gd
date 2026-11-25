class_name CautionState
extends EnemyState
## Cautela: anda devagar com a guarda erguida, olhando para o alvo. Chega só até Y, circula o alvo
## e recua se ele chegar mais perto. Termina (`LUNGE_READY`) depois de `time_to_lunge` segundos
## perto do alvo ou `reflect_lunge_delay` segundos depois de defender um golpe.

enum Reason { LUNGE_READY }

@export var behavior: MeleeBehaviorConfig
## Guarda erguida durante a cautela (a do capanga reflete os golpes defendidos).
@export var guard: GuardComponent
## Para saber quando um golpe foi defendido pela guarda.
@export var hurt_box: HurtBox

var _active: bool = false
var _near_time: float = 0.0
var _strafe_sign: float = 1.0
var _flip_timer: float = 0.0
# Negativo enquanto nenhum golpe foi defendido nesta cautela.
var _reflect_time: float = -1.0


## Recebe o contexto e passa a ouvir os golpes recebidos.
func setup(agent_context: AgentContext) -> void:
	super(agent_context)
	hurt_box.hit_received.connect(_on_hurt_box_hit_received)


## Ergue a guarda, zera os tempos e sorteia o sentido em que vai circular.
func enter() -> void:
	_active = true
	_near_time = 0.0
	_reflect_time = -1.0
	_strafe_sign = 1.0 if randf() < 0.5 else -1.0
	_flip_timer = randf_range(behavior.strafe_flip_min, behavior.strafe_flip_max)
	guard.raise()


## Abaixa a guarda.
func exit() -> void:
	_active = false
	guard.lower(GuardModel.LowerReason.RELEASED)


## Olha para o alvo, move-se pela distância, conta os tempos e avisa quando é hora da investida.
func physics_update(delta: float) -> void:
	var distance: float = context.distance_to_target()
	var to_target: Vector3 = context.direction_to_target()
	if not guard.is_raised():
		guard.raise()
	context.locomotion.face_direction(to_target, delta)
	context.locomotion.move(_caution_velocity(distance, to_target, delta), delta)
	if MeleeBehaviorRules.counts_toward_lunge(distance, behavior):
		_near_time += delta
	else:
		_near_time = 0.0
	if _reflect_time >= 0.0:
		_reflect_time += delta
	var reflect_ready: bool = _reflect_time >= behavior.reflect_lunge_delay
	if _near_time >= behavior.time_to_lunge or reflect_ready:
		finished.emit(Reason.LUNGE_READY)


## Devolve a velocidade da cautela: avança, recua ou orbita o alvo na distância atual, trocando o
## sentido do giro de tempos em tempos.
func _caution_velocity(distance: float, to_target: Vector3, delta: float) -> Vector3:
	match MeleeBehaviorRules.caution_move(distance, behavior):
		MeleeBehaviorRules.CautionMove.ADVANCE:
			return to_target * behavior.caution_speed
		MeleeBehaviorRules.CautionMove.RETREAT:
			return -to_target * behavior.caution_speed
	_flip_timer -= delta
	if _flip_timer <= 0.0:
		_strafe_sign = -_strafe_sign
		_flip_timer = randf_range(behavior.strafe_flip_min, behavior.strafe_flip_max)
	return CombatGeometry.orbit_velocity(
		context.target.global_position,
		context.body.global_position,
		distance,
		behavior.strafe_speed,
		_strafe_sign,
		delta
	)


## Um golpe defendido pela guarda durante a cautela agenda a investida.
func _on_hurt_box_hit_received(_hit: HitInfo, outcome: int) -> void:
	if _active and HitResolver.is_blocked(outcome) and _reflect_time < 0.0:
		_reflect_time = 0.0
