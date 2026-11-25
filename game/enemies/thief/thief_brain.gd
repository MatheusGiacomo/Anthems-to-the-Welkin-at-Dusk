class_name ThiefBrain
extends EnemyBrain
## Cérebro do ladrão: aproxima-se e atira com o arco a distância X. Ao sair da vulnerabilidade com
## o alvo perto, sorteia entre fugir e lutar com a adaga (com as `MeleeTactics` do capanga) até
## voltar à distância X.

@export var ranged: RangedBehaviorConfig
## Perfil corpo a corpo da luta com a adaga.
@export var melee: MeleeBehaviorConfig
@export var chase_state: ChaseState
@export var shoot_state: RangedAttackState
@export var flee_state: FleeState
@export_group("Luta com a adaga")
@export var melee_chase_state: ChaseState
@export var caution_state: CautionState
@export var lunge_state: LungeState

var _tactics: MeleeTactics
var _mode: ThiefRules.Mode = ThiefRules.Mode.CHASE


## Dá as velocidades à aproximação e à fuga e monta as táticas da adaga.
func _ready() -> void:
	super()
	chase_state.speed = ranged.run_speed
	flee_state.speed = ranged.flee_speed
	_tactics = MeleeTactics.new(melee_chase_state, caution_state, lunge_state, melee)


## Devolve o modo atual (`ThiefRules.Mode`).
func get_mode() -> ThiefRules.Mode:
	return _mode


## Começa correndo até o alvo, ou atirando se ele já estiver a até X.
func _start_combat() -> void:
	var distance: float = context.distance_to_target()
	_enter_mode(ThiefRules.distance_mode(ThiefRules.Mode.CHASE, distance, ranged))


## Troca de modo pela distância: entre aproximação e tiro; da fuga e da luta de volta ao tiro ao
## chegar a X; dentro da luta, entre aproximação e cautela da adaga.
func _update_combat() -> void:
	var distance: float = context.distance_to_target()
	match _mode:
		ThiefRules.Mode.CHASE, ThiefRules.Mode.SHOOT:
			var next: ThiefRules.Mode = ThiefRules.distance_mode(_mode, distance, ranged)
			if next != _mode:
				_enter_mode(next)
		ThiefRules.Mode.FLEE:
			if ThiefRules.is_back_at_range(distance, ranged):
				_enter_mode(ThiefRules.Mode.SHOOT)
		ThiefRules.Mode.FIGHT:
			if ThiefRules.is_back_at_range(distance, ranged):
				_enter_mode(ThiefRules.Mode.SHOOT)
				return
			var melee_next: EnemyState = _tactics.state_for_distance(current, distance)
			if melee_next != null:
				transition_to(melee_next)


## Ao sair da vulnerabilidade: com o alvo perto, sorteia fuga ou luta; longe, segue pela
## distância.
func _resume_after_stagger() -> void:
	_enter_mode(ThiefRules.after_stagger(context.distance_to_target(), ranged, randf()))


## Na luta com a adaga, a cautela pronta leva à investida e a investida segue a tabela de decisão.
func _on_current_finished(state: State, _reason: int) -> void:
	if _mode != ThiefRules.Mode.FIGHT:
		return
	var next: EnemyState = _tactics.state_after_finished(state, context.distance_to_target())
	if next != null:
		transition_to(next)


## Entra no estado de `mode`; a luta começa em cautela, ou aproximação se o alvo se afastou.
func _enter_mode(mode: ThiefRules.Mode) -> void:
	_mode = mode
	match mode:
		ThiefRules.Mode.CHASE:
			transition_to(chase_state)
		ThiefRules.Mode.SHOOT:
			transition_to(shoot_state)
		ThiefRules.Mode.FLEE:
			transition_to(flee_state)
		ThiefRules.Mode.FIGHT:
			transition_to(_tactics.state_after_stagger(context.distance_to_target()))
