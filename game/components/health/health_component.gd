class_name HealthComponent
extends Node
## Vida de uma entidade. No V1 ela só perde vida (não há cura) e avisa quando chega a zero.

signal damaged(amount: float, remaining: float)
signal died

## Vida no início e depois de `reset()`.
@export var max_health: float = 100.0

var current_health: float = 0.0


## Começa com a vida cheia.
func _ready() -> void:
	reset()


## Tira `amount` da vida, sem passar de zero, e emite `damaged`. Emite `died` uma única vez, no
## golpe que zera a vida. Ignora dano não positivo e dano em quem já morreu.
func damage(amount: float) -> void:
	if is_dead() or amount <= 0.0:
		return
	current_health = maxf(current_health - amount, 0.0)
	damaged.emit(amount, current_health)
	if is_dead():
		died.emit()


## Devolve se a vida chegou a zero.
func is_dead() -> bool:
	return current_health <= 0.0


## Enche a vida até `max_health`, sem emitir sinais.
func reset() -> void:
	current_health = max_health
