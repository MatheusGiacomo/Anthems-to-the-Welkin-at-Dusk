class_name FleeState
extends EnemyState
## Fuga: corre na direção oposta à do alvo, olhando para onde corre. Não termina sozinho: o
## cérebro troca de estado pela distância.

## Metros por segundo; atribuída pelo cérebro a partir da config de comportamento.
var speed: float = 0.0


## Corre e olha para longe do alvo.
func physics_update(delta: float) -> void:
	var away: Vector3 = -context.direction_to_target()
	context.locomotion.face_direction(away, delta)
	context.locomotion.move(away * speed, delta)
