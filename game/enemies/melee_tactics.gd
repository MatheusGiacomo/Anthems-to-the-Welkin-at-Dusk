class_name MeleeTactics
extends RefCounted
## Decisões do combate corpo a corpo (aproximação, cautela e investida) sobre um trio de estados,
## seguindo `MeleeBehaviorRules`. Devolve o próximo estado; quem troca é o cérebro. Usado pelo
## capanga e pelo ladrão na luta com a adaga.

var chase: ChaseState
var caution: CautionState
var lunge: LungeState
var behavior: MeleeBehaviorConfig


## Cria as táticas sobre os três estados e dá à aproximação a velocidade de corrida de `config`.
func _init(
	chase_state: ChaseState,
	caution_state: CautionState,
	lunge_state: LungeState,
	config: MeleeBehaviorConfig,
) -> void:
	chase = chase_state
	caution = caution_state
	lunge = lunge_state
	behavior = config
	chase.speed = behavior.run_speed


## Devolve se `state` é um dos estados destas táticas.
func owns(state: State) -> bool:
	return state == chase or state == caution or state == lunge


## Devolve o estado ao entrar em combate corpo a corpo com o alvo a `distance`.
func state_for_start(distance: float) -> EnemyState:
	var mode: MeleeBehaviorRules.Mode = MeleeBehaviorRules.distance_mode(
		MeleeBehaviorRules.Mode.CHASE, distance, behavior
	)
	return _state_for(mode)


## Devolve o novo estado se a distância pede troca entre aproximação e cautela, ou nulo. A
## investida nunca é trocada pela distância.
func state_for_distance(current: State, distance: float) -> EnemyState:
	if current != chase and current != caution:
		return null
	var mode: MeleeBehaviorRules.Mode = (
		MeleeBehaviorRules.Mode.CHASE if current == chase else MeleeBehaviorRules.Mode.CAUTION
	)
	var next: MeleeBehaviorRules.Mode = MeleeBehaviorRules.distance_mode(mode, distance, behavior)
	return null if next == mode else _state_for(next)


## Devolve o estado ao sair da vulnerabilidade com o alvo a `distance`.
func state_after_stagger(distance: float) -> EnemyState:
	return _state_for(MeleeBehaviorRules.after_stagger(distance, behavior))


## Devolve o estado depois que `state` terminou: a cautela leva à investida; a investida segue a
## tabela de `MeleeBehaviorRules.after_lunge`. Nulo para outros estados.
func state_after_finished(state: State, distance: float) -> EnemyState:
	if state == caution:
		return lunge
	if state == lunge:
		return _state_for(MeleeBehaviorRules.after_lunge(lunge.result, distance, behavior))
	return null


## Devolve o estado de cada modo.
func _state_for(mode: MeleeBehaviorRules.Mode) -> EnemyState:
	match mode:
		MeleeBehaviorRules.Mode.CHASE:
			return chase
		MeleeBehaviorRules.Mode.LUNGE:
			return lunge
	return caution
