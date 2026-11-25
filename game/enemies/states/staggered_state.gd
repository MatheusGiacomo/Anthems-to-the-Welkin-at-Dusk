class_name StaggeredState
extends EnemyState
## Vulnerável (atordoado): não age, só freia. O cérebro entra aqui em `vulnerable_started` e sai
## em `vulnerable_ended`.


## Freia até parar.
func physics_update(delta: float) -> void:
	context.locomotion.move(Vector3.ZERO, delta)
