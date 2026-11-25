class_name HenchmanBrain
extends EnemyBrain
## Cérebro do capanga: só combate corpo a corpo (aproximação, cautela e investida), decidido por
## `MeleeTactics`.

@export var behavior: MeleeBehaviorConfig
@export var chase_state: ChaseState
@export var caution_state: CautionState
@export var lunge_state: LungeState

var _tactics: MeleeTactics


## Monta as táticas sobre os estados da cena.
func _ready() -> void:
	super()
	_tactics = MeleeTactics.new(chase_state, caution_state, lunge_state, behavior)


## Começa correndo até o alvo, ou em cautela se ele já estiver perto.
func _start_combat() -> void:
	transition_to(_tactics.state_for_start(context.distance_to_target()))


## Troca entre aproximação e cautela pela distância.
func _update_combat() -> void:
	var next: EnemyState = _tactics.state_for_distance(current, context.distance_to_target())
	if next != null:
		transition_to(next)


## Ao sair da vulnerabilidade, vai para a cautela, ou para a aproximação se o alvo se afastou.
func _resume_after_stagger() -> void:
	transition_to(_tactics.state_after_stagger(context.distance_to_target()))


## A cautela pronta leva à investida; a investida completa segue a tabela de decisão.
func _on_current_finished(state: State, _reason: int) -> void:
	var next: EnemyState = _tactics.state_after_finished(state, context.distance_to_target())
	if next != null:
		transition_to(next)
