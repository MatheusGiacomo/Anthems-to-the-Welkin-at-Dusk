class_name Ballistics
extends RefCounted
## Funções puras de tiro balístico.

# Abaixo disso, a distância no chão é considerada nula.
const MIN_DISTANCE: float = 0.001
# Ângulo de alcance máximo, usado quando o alvo está longe demais para a velocidade.
const MAX_RANGE_ANGLE: float = PI / 4.0


## Devolve a velocidade de lançamento, com módulo `speed`, para um projétil sob `gravity` (m/s²)
## sair de `from` e passar por `to`, pela trajetória mais baixa. Sem gravidade, mira em linha
## reta. Se o alvo estiver fora de alcance, lança a 45°, o ângulo de maior alcance.
static func launch_velocity(from: Vector3, to: Vector3, speed: float, gravity: float) -> Vector3:
	var flat: Vector3 = CombatGeometry.flatten(to - from)
	var distance: float = flat.length()
	if gravity <= 0.0 or distance < MIN_DISTANCE:
		return (to - from).normalized() * speed
	var height: float = to.y - from.y
	var speed_squared: float = speed * speed
	var discriminant: float = (
		speed_squared * speed_squared
		- gravity * (gravity * distance * distance + 2.0 * height * speed_squared)
	)
	var angle: float = MAX_RANGE_ANGLE
	if discriminant >= 0.0:
		angle = atan((speed_squared - sqrt(discriminant)) / (gravity * distance))
	var direction: Vector3 = flat / distance
	return direction * speed * cos(angle) + Vector3.UP * speed * sin(angle)
