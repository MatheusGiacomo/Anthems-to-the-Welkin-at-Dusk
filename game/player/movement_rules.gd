class_name MovementRules
extends RefCounted
## Regras puras do movimento do player.

# Abaixo disso, uma direção é considerada nula.
const MIN_DIRECTION_SQUARED: float = 0.0001


## Devolve o multiplicador de velocidade pelo alinhamento entre `move_direction` e `facing` (no
## chão): `forward_multiplier` andando para onde olha, `backward_multiplier` de costas, e a
## interpolação linear pelo cosseno do ângulo entre eles no meio (de lado, a média dos dois).
## Com alguma direção nula, devolve `forward_multiplier`.
static func alignment_multiplier(
	move_direction: Vector3,
	facing: Vector3,
	forward_multiplier: float,
	backward_multiplier: float,
) -> float:
	var move: Vector3 = CombatGeometry.flatten(move_direction)
	var face: Vector3 = CombatGeometry.flatten(facing)
	if (
		move.length_squared() < MIN_DIRECTION_SQUARED
		or face.length_squared() < MIN_DIRECTION_SQUARED
	):
		return forward_multiplier
	var alignment: float = move.normalized().dot(face.normalized())
	return lerpf(backward_multiplier, forward_multiplier, (alignment + 1.0) * 0.5)


## Converte o input de movimento (x = direita, y = para trás, como `Input.get_vector`) em direção
## no chão relativa a uma câmera girada `camera_yaw` radianos em Y, com comprimento até 1.
## Assim, "para frente" é sempre "para cima na tela".
static func camera_relative_direction(input: Vector2, camera_yaw: float) -> Vector3:
	var local: Vector3 = Vector3(input.x, 0.0, input.y)
	return local.rotated(Vector3.UP, camera_yaw).limit_length(1.0)
