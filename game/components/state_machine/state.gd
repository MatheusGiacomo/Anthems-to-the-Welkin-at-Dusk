class_name State
extends Node
## Um comportamento de uma `StateMachine`. Não conhece os outros estados: quando termina o que
## faz, emite `finished` com um motivo, e a máquina decide o próximo.

## `reason` é um valor definido por cada estado (um enum dele).
signal finished(reason: int)


## Chamado ao entrar no estado.
func enter() -> void:
	pass


## Chamado ao sair do estado, antes de entrar no próximo.
func exit() -> void:
	pass


## Chamado a cada quadro de física enquanto este é o estado atual.
func physics_update(_delta: float) -> void:
	pass
