class_name IdleState
extends EnemyState
## Parado no lugar, sem alvo: o inimigo recém-spawnado ou fora de combate.


## Freia até parar.
func physics_update(delta: float) -> void:
	context.locomotion.move(Vector3.ZERO, delta)
