extends GdUnitTestSuite
## Geometria do combate no chão: arco frontal, direção e ângulo para olhar.

const FORWARD: Vector3 = Vector3(0.0, 0.0, -1.0)


func test_point_ahead_is_within_arc() -> void:
	assert_bool(CombatGeometry.is_within_arc(FORWARD, Vector3(0.0, 0.0, -3.0), 120.0)).is_true()


func test_point_behind_is_outside_arc() -> void:
	assert_bool(CombatGeometry.is_within_arc(FORWARD, Vector3(0.0, 0.0, 3.0), 120.0)).is_false()


func test_arc_limit_is_half_the_angle_to_each_side() -> void:
	var at_50_degrees: Vector3 = FORWARD.rotated(Vector3.UP, deg_to_rad(50.0))
	var at_70_degrees: Vector3 = FORWARD.rotated(Vector3.UP, deg_to_rad(70.0))
	assert_bool(CombatGeometry.is_within_arc(FORWARD, at_50_degrees, 120.0)).is_true()
	assert_bool(CombatGeometry.is_within_arc(FORWARD, at_70_degrees, 120.0)).is_false()


func test_height_is_ignored() -> void:
	var above_ahead: Vector3 = Vector3(0.0, 10.0, -1.0)
	assert_bool(CombatGeometry.is_within_arc(FORWARD, above_ahead, 30.0)).is_true()


func test_same_position_counts_as_within() -> void:
	assert_bool(CombatGeometry.is_within_arc(FORWARD, Vector3.ZERO, 10.0)).is_true()


func test_direction_on_ground_is_flat_and_normalized() -> void:
	var direction: Vector3 = CombatGeometry.direction_on_ground(
		Vector3(0.0, 1.0, 0.0), Vector3(4.0, 5.0, 0.0)
	)
	assert_vector(direction).is_equal_approx(Vector3(1.0, 0.0, 0.0), Vector3.ONE * 0.001)


func test_orbit_keeps_the_radius() -> void:
	var center: Vector3 = Vector3(1.0, 0.0, 1.0)
	var position: Vector3 = center + Vector3(0.0, 0.0, 3.0)
	for step: int in 120:
		position += (
			CombatGeometry.orbit_velocity(center, position, 3.0, 1.5, 1.0, 1.0 / 60.0) / 60.0
		)
	assert_float(CombatGeometry.flatten(position - center).length()).is_equal_approx(3.0, 0.001)


func test_orbit_moves_at_the_given_speed() -> void:
	var velocity: Vector3 = CombatGeometry.orbit_velocity(
		Vector3.ZERO, Vector3(0.0, 0.0, 3.0), 3.0, 1.5, -1.0, 1.0 / 60.0
	)
	assert_float(velocity.length()).is_equal_approx(1.5, 0.01)


func test_yaw_makes_node_look_at_direction() -> void:
	var direction: Vector3 = Vector3(1.0, 0.0, 1.0).normalized()
	var basis: Basis = Basis(Vector3.UP, CombatGeometry.yaw_for_direction(direction))
	assert_vector(-basis.z).is_equal_approx(direction, Vector3.ONE * 0.001)
