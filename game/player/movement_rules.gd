class_name MovementRules
extends RefCounted
## Regras puras do movimento do player.


## Converte o input de movimento (x = direita, y = para trás, como `Input.get_vector`) em direção
## no chão relativa a uma câmera girada `camera_yaw` radianos em Y, com comprimento até 1.
## Assim, "para frente" é sempre "para cima na tela".
static func camera_relative_direction(input: Vector2, camera_yaw: float) -> Vector3:
	var local: Vector3 = Vector3(input.x, 0.0, input.y)
	return local.rotated(Vector3.UP, camera_yaw).limit_length(1.0)
