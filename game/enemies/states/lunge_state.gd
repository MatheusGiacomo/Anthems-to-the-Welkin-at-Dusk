class_name LungeState
extends EnemyState
## Investida: sem guarda, avança na direção do alvo durante o preparo do ataque e golpeia. A
## direção e o avanço são fixados no início. Não troca de estado sozinha: termina (`DONE`) quando o
## ataque acaba e guarda em `result` o que aconteceu, para o cérebro decidir o passo seguinte.

enum Reason { DONE }

@export var behavior: MeleeBehaviorConfig
@export var attack: MeleeAttackComponent

## O que aconteceu na última investida (`MeleeBehaviorRules.LungeResult`).
var result: MeleeBehaviorRules.LungeResult = MeleeBehaviorRules.LungeResult.NONE

var _active: bool = false
var _started: bool = false
var _direction: Vector3 = Vector3.ZERO
var _lunge_speed: float = 0.0


## Recebe o contexto e passa a ouvir o ataque e o resultado do golpe.
func setup(agent_context: AgentContext) -> void:
	super(agent_context)
	attack.attack_finished.connect(_on_attack_attack_finished)
	attack.hit_box.hit_resolved.connect(_on_hit_box_hit_resolved)


## Fixa a direção (vira para o alvo na hora) e a velocidade do avanço pela distância ao alvo.
func enter() -> void:
	_active = true
	_started = false
	result = MeleeBehaviorRules.LungeResult.NONE
	_direction = context.direction_to_target()
	if _direction == Vector3.ZERO:
		_direction = context.locomotion.get_forward()
	context.locomotion.snap_to_direction(_direction)
	var lunge: float = MeleeBehaviorRules.lunge_distance(context.distance_to_target(), behavior)
	_lunge_speed = lunge / attack.data.windup if attack.data.windup > 0.0 else 0.0


## Cancela o ataque se a investida for interrompida.
func exit() -> void:
	_active = false
	attack.cancel()


## Começa o ataque assim que ele estiver livre; avança durante o preparo e para no golpe e na
## recuperação.
func physics_update(delta: float) -> void:
	if not _started:
		_started = attack.try_attack()
	if _started and attack.get_phase() == AttackCycle.Phase.WINDUP:
		context.locomotion.move(_direction * _lunge_speed, delta)
	else:
		context.locomotion.move(Vector3.ZERO, delta)


## O ataque completo encerra a investida.
func _on_attack_attack_finished(completed: bool) -> void:
	if _active and completed:
		finished.emit(Reason.DONE)


## Guarda o resultado do golpe: acertou, foi defendido ou trombou.
func _on_hit_box_hit_resolved(_hurt_box: HurtBox, outcome: int) -> void:
	if not _active:
		return
	if outcome == HitResolver.Outcome.HIT:
		result = MeleeBehaviorRules.LungeResult.HIT_TARGET
	elif outcome == HitResolver.Outcome.CLASHED:
		result = MeleeBehaviorRules.LungeResult.CLASHED
	elif HitResolver.is_blocked(outcome):
		result = MeleeBehaviorRules.LungeResult.BLOCKED
