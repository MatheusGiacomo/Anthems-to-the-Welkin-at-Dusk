extends GdUnitTestSuite
## Movimento do player na cena: andar para onde olha é mais rápido que andar de costas.
## Sem câmera, o player olha para -Z, e "para frente" também é -Z.

const PLAYER_SCENE: String = "res://player/player.tscn"
## Quadros de física para a velocidade estabilizar (a aceleração leva cerca de 0,15 s).
const SETTLE_PHYSICS_FRAMES: int = 30


func _speed_while_holding(action: String) -> float:
	var runner: GdUnitSceneRunner = scene_runner(PLAYER_SCENE)
	var player: Player = runner.scene() as Player
	runner.simulate_action_press(action)
	for frame: int in SETTLE_PHYSICS_FRAMES:
		await get_tree().physics_frame
	var speed: float = player.velocity.length()
	runner.simulate_action_release(action)
	return speed


func test_moving_where_facing_reaches_full_speed() -> void:
	var speed: float = await _speed_while_holding("move_forward")
	# move_speed 5 × forward_multiplier 1.
	assert_float(speed).is_between(4.5, 5.1)


func test_moving_backwards_is_slower() -> void:
	var speed: float = await _speed_while_holding("move_back")
	# move_speed 5 × backward_multiplier 0,6.
	assert_float(speed).is_between(2.6, 3.2)
