extends GdUnitTestSuite
## Regras do movimento do player: multiplicador por alinhamento e direção relativa à câmera.

const FORWARD_MULTIPLIER: float = 1.0
const BACKWARD_MULTIPLIER: float = 0.6
const FACING: Vector3 = Vector3(0.0, 0.0, -1.0)


func _multiplier(move_direction: Vector3) -> float:
	return MovementRules.alignment_multiplier(
		move_direction, FACING, FORWARD_MULTIPLIER, BACKWARD_MULTIPLIER
	)


func test_moving_where_facing_uses_forward_multiplier() -> void:
	assert_float(_multiplier(FACING)).is_equal_approx(FORWARD_MULTIPLIER, 0.001)


func test_moving_backwards_uses_backward_multiplier() -> void:
	assert_float(_multiplier(-FACING)).is_equal_approx(BACKWARD_MULTIPLIER, 0.001)


func test_moving_sideways_uses_the_average() -> void:
	var average: float = (FORWARD_MULTIPLIER + BACKWARD_MULTIPLIER) * 0.5
	assert_float(_multiplier(Vector3.RIGHT)).is_equal_approx(average, 0.001)


func test_more_aligned_is_faster() -> void:
	var diagonal_forward: Vector3 = Vector3(1.0, 0.0, -1.0)
	var diagonal_backward: Vector3 = Vector3(1.0, 0.0, 1.0)
	assert_float(_multiplier(diagonal_forward)).is_greater(_multiplier(Vector3.RIGHT))
	assert_float(_multiplier(Vector3.RIGHT)).is_greater(_multiplier(diagonal_backward))


func test_magnitude_and_height_do_not_change_multiplier() -> void:
	assert_float(_multiplier(Vector3(0.0, 5.0, -10.0))).is_equal_approx(FORWARD_MULTIPLIER, 0.001)


func test_no_movement_uses_forward_multiplier() -> void:
	assert_float(_multiplier(Vector3.ZERO)).is_equal_approx(FORWARD_MULTIPLIER, 0.001)


func test_forward_input_goes_up_the_screen() -> void:
	var direction: Vector3 = MovementRules.camera_relative_direction(Vector2(0.0, -1.0), 0.0)
	assert_vector(direction).is_equal_approx(Vector3(0.0, 0.0, -1.0), Vector3.ONE * 0.001)


func test_direction_follows_camera_yaw() -> void:
	var yaw: float = deg_to_rad(90.0)
	var direction: Vector3 = MovementRules.camera_relative_direction(Vector2(0.0, -1.0), yaw)
	assert_vector(direction).is_equal_approx(Vector3(-1.0, 0.0, 0.0), Vector3.ONE * 0.001)


func test_direction_length_is_at_most_one() -> void:
	var direction: Vector3 = MovementRules.camera_relative_direction(Vector2(3.0, 4.0), 0.0)
	assert_float(direction.length()).is_equal_approx(1.0, 0.001)
