class_name CombatGeometry
extends RefCounted
## Funções puras de geometria do combate no plano do chão (o eixo Y é ignorado). A frente de uma
## entidade é o -Z do nó, convenção do Godot.

# Folga para o limite exato do arco não depender de arredondamento.
const ARC_EPSILON: float = 0.0001


## Devolve `vector` sem a componente vertical.
static func flatten(vector: Vector3) -> Vector3:
	return Vector3(vector.x, 0.0, vector.z)


## Devolve a direção, no chão e normalizada, de `from` até `to` (zero se coincidirem no chão).
static func direction_on_ground(from: Vector3, to: Vector3) -> Vector3:
	return flatten(to - from).normalized()


## Devolve a frente de `node` no chão, normalizada.
static func forward_of(node: Node3D) -> Vector3:
	return flatten(-node.global_basis.z).normalized()


## Devolve o ângulo em Y (radianos) que faz um nó olhar para `direction`.
static func yaw_for_direction(direction: Vector3) -> float:
	return atan2(-direction.x, -direction.z)


## Devolve a velocidade que leva `position` a girar em volta de `center`, no raio `radius`, a
## `speed` metros por segundo, no sentido de `direction_sign` (+1 anti-horário visto de cima).
## Corrige o raio no mesmo passo, então quem orbita não se afasta em espiral. Zero se `position`
## coincidir com `center` no chão ou se `delta` não for positivo.
static func orbit_velocity(
	center: Vector3,
	position: Vector3,
	radius: float,
	speed: float,
	direction_sign: float,
	delta: float,
) -> Vector3:
	var offset: Vector3 = flatten(position - center)
	if offset.length_squared() < ARC_EPSILON or delta <= 0.0 or radius <= 0.0:
		return Vector3.ZERO
	var angle_step: float = direction_sign * speed * delta / radius
	var next_offset: Vector3 = offset.normalized().rotated(Vector3.UP, angle_step) * radius
	return (next_offset - offset) / delta


## Devolve se `to_point` (vetor de quem olha até o ponto) está dentro do arco de `arc_degrees`
## centrado em `forward`. Um ponto na mesma posição conta como dentro.
static func is_within_arc(forward: Vector3, to_point: Vector3, arc_degrees: float) -> bool:
	var direction: Vector3 = flatten(to_point)
	if direction.length_squared() < ARC_EPSILON:
		return true
	var facing: Vector3 = flatten(forward).normalized()
	var min_dot: float = cos(deg_to_rad(arc_degrees * 0.5))
	return facing.dot(direction.normalized()) >= min_dot - ARC_EPSILON
