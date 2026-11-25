class_name StateMachine
extends Node
## Máquina de estados em nós: os filhos `State` são os estados. Roda o estado atual a cada quadro
## de física e repassa a `_on_current_finished` o fim dele; subclasses decidem as transições.

signal state_changed(state: State)

## Estado atual (nulo antes da primeira transição).
var current: State = null


## Escuta o `finished` de cada estado filho.
func _ready() -> void:
	for child: Node in get_children():
		var state: State = child as State
		if state != null:
			state.finished.connect(_on_state_finished.bind(state))


## Roda o estado atual.
func _physics_process(delta: float) -> void:
	if current != null:
		current.physics_update(delta)


## Sai do estado atual e entra em `state` (entra de novo se for o mesmo) e emite `state_changed`.
func transition_to(state: State) -> void:
	if current != null:
		current.exit()
	current = state
	if current != null:
		current.enter()
	state_changed.emit(current)


## Devolve o nome do nó do estado atual, ou vazio se não houver estado.
func get_state_name() -> StringName:
	return current.name if current != null else &""


## Ponto de extensão: chamado quando o estado atual emite `finished`. Por padrão, nada muda.
func _on_current_finished(_state: State, _reason: int) -> void:
	pass


## Repassa o `finished` só se vier do estado atual (um estado que já saiu não decide nada).
func _on_state_finished(reason: int, state: State) -> void:
	if state == current:
		_on_current_finished(state, reason)
