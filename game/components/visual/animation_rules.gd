class_name AnimationRules
extends RefCounted
## Regras puras do animador: qual clipe tocar para o estado da entidade e em que velocidade.

enum Clip {
	IDLE,
	WALK,
	WALK_BACKWARD,
	RUN,
	STRAFE_LEFT,
	STRAFE_RIGHT,
	ATTACK,
	GUARD,
	GUARD_HIT,
	STAGGER,
	DEATH,
	AIM,
	SHOOT,
}


## Devolve o clipe do estado, nesta prioridade: morte, atordoado, golpe, puxada, tiro, guarda
## (defesa ou erguida) e, por fim, a locomoção.
static func pick(state: AnimationState, animations: AnimationSet) -> Clip:
	if state.dead:
		return Clip.DEATH
	if state.staggered:
		return Clip.STAGGER
	if state.attacking:
		return Clip.ATTACK
	if state.drawing:
		return Clip.AIM
	if state.recently_shot:
		return Clip.SHOOT
	if state.guarding:
		return Clip.GUARD_HIT if state.guard_hit else Clip.GUARD
	return locomotion_clip(state.velocity, state.facing, animations)


## Devolve o clipe de locomoção pela velocidade em relação à frente: parado abaixo de
## `idle_speed`; de costas quando o movimento para trás predomina; de lado quando o movimento
## lateral predomina; para a frente, correr a partir de `run_threshold`, senão andar.
static func locomotion_clip(velocity: Vector3, facing: Vector3, animations: AnimationSet) -> Clip:
	var flat: Vector3 = CombatGeometry.flatten(velocity)
	var speed: float = flat.length()
	if speed < animations.idle_speed:
		return Clip.IDLE
	var forward: Vector3 = CombatGeometry.flatten(facing).normalized()
	var right: Vector3 = forward.cross(Vector3.UP)
	var ahead: float = flat.dot(forward)
	var side: float = flat.dot(right)
	if -ahead >= absf(side):
		return Clip.WALK_BACKWARD
	if absf(side) > ahead:
		return Clip.STRAFE_RIGHT if side > 0.0 else Clip.STRAFE_LEFT
	return Clip.RUN if speed >= animations.run_threshold else Clip.WALK


## Devolve a velocidade de reprodução de `clip`, cujo comprimento é `clip_length` segundos: o
## golpe e a puxada duram o mesmo que o ataque e a puxada do jogo; a locomoção acompanha a
## velocidade real; os demais tocam na velocidade normal.
static func playback_speed(
	clip: Clip, state: AnimationState, animations: AnimationSet, clip_length: float
) -> float:
	var speed: float = CombatGeometry.flatten(state.velocity).length()
	match clip:
		Clip.ATTACK:
			return _fit(clip_length, state.attack_duration)
		Clip.AIM:
			return _fit(clip_length, state.draw_duration)
		Clip.WALK, Clip.WALK_BACKWARD:
			return speed / animations.walk_reference_speed
		Clip.RUN, Clip.STRAFE_LEFT, Clip.STRAFE_RIGHT:
			return speed / animations.run_reference_speed
	return 1.0


## Devolve a velocidade que faz um clipe de `clip_length` segundos durar `duration` segundos
## (1 se alguma duração não for positiva).
static func _fit(clip_length: float, duration: float) -> float:
	if clip_length <= 0.0 or duration <= 0.0:
		return 1.0
	return clip_length / duration
