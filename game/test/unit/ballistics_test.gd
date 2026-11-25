extends GdUnitTestSuite
## Tiro balístico: a trajetória calculada passa pelo alvo, sem gravidade é reta e fora de alcance
## lança a 45°.

const SPEED: float = 18.0
const GRAVITY: float = 9.8
const STEP: float = 1.0 / 240.0


## Simula o voo até a distância no chão do alvo e devolve a altura nesse ponto.
func _height_at_target(from: Vector3, to: Vector3, velocity: Vector3) -> float:
	var position: Vector3 = from
	var current: Vector3 = velocity
	var target_distance: float = CombatGeometry.flatten(to - from).length()
	while CombatGeometry.flatten(position - from).length() < target_distance:
		current.y -= GRAVITY * STEP
		position += current * STEP
	return position.y


func test_trajectory_passes_through_target() -> void:
	var from: Vector3 = Vector3(0.0, 1.3, 0.0)
	var to: Vector3 = Vector3(6.0, 1.0, -8.0)
	var velocity: Vector3 = Ballistics.launch_velocity(from, to, SPEED, GRAVITY)
	assert_float(velocity.length()).is_equal_approx(SPEED, 0.001)
	assert_float(_height_at_target(from, to, velocity)).is_between(to.y - 0.1, to.y + 0.1)


func test_without_gravity_aims_straight() -> void:
	var from: Vector3 = Vector3.ZERO
	var to: Vector3 = Vector3(0.0, 0.0, -10.0)
	var velocity: Vector3 = Ballistics.launch_velocity(from, to, SPEED, 0.0)
	assert_vector(velocity).is_equal_approx(Vector3(0.0, 0.0, -SPEED), Vector3.ONE * 0.001)


func test_out_of_range_launches_at_45_degrees() -> void:
	var velocity: Vector3 = Ballistics.launch_velocity(
		Vector3.ZERO, Vector3(1000.0, 0.0, 0.0), SPEED, GRAVITY
	)
	assert_float(velocity.y).is_equal_approx(velocity.x, 0.001)
