class_name ChaseState
extends EnemyState
## Corre em direção ao alvo, olhando para onde corre (estado de aproximação). Não termina sozinho:
## o cérebro troca de estado pela distância.

## Metros por segundo; atribuída pelo cérebro a partir da config de comportamento.
var speed: float = 0.0


## Corre e olha em direção ao alvo.
func physics_update(delta: float) -> void:
	var direction: Vector3 = context.direction_to_target()
	context.locomotion.face_direction(direction, delta)
	context.locomotion.move(direction * speed, delta)
