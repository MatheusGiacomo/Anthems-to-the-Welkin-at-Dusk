extends GdUnitTestSuite
## Regras do movimento do player: direção relativa à câmera.


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
