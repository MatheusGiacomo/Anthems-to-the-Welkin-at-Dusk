extends GdUnitTestSuite
## Movimento do player na cena: mesma velocidade em qualquer direção, olhar para onde anda e
## olhar travado com o escudo erguido. Sem câmera, o player começa olhando para -Z, e "para
## frente" também é -Z.

const PLAYER_SCENE: String = "res://player/player.tscn"
## Quadros de física para a velocidade e o giro estabilizarem (a aceleração leva cerca de 0,15 s).
const SETTLE_PHYSICS_FRAMES: int = 30


## Segura `action` (e `extra`, se dado) por `SETTLE_PHYSICS_FRAMES` e devolve o player.
func _hold(runner: GdUnitSceneRunner, action: String, extra: String = "") -> Player:
	var player: Player = runner.scene() as Player
	if not extra.is_empty():
		runner.simulate_action_press(extra)
	runner.simulate_action_press(action)
	for frame: int in SETTLE_PHYSICS_FRAMES:
		# Reafirma o escudo a cada quadro: a janela de teste pode perder o foco e soltar a ação.
		if not extra.is_empty() and not Input.is_action_pressed(extra):
			runner.simulate_action_press(extra)
		await get_tree().physics_frame
	return player


func test_moving_forward_reaches_full_speed() -> void:
	var runner: GdUnitSceneRunner = scene_runner(PLAYER_SCENE)
	var player: Player = await _hold(runner, "move_forward")
	# move_speed 5.
	assert_float(player.velocity.length()).is_between(4.5, 5.1)


func test_moving_backwards_has_the_same_speed() -> void:
	var runner: GdUnitSceneRunner = scene_runner(PLAYER_SCENE)
	var player: Player = await _hold(runner, "move_back")
	assert_float(player.velocity.length()).is_between(4.5, 5.1)


func test_player_turns_to_where_it_walks() -> void:
	var runner: GdUnitSceneRunner = scene_runner(PLAYER_SCENE)
	var player: Player = await _hold(runner, "move_back")
	var forward: Vector3 = CombatGeometry.forward_of(player)
	assert_float(forward.dot(Vector3.BACK)).is_greater(0.95)


func test_raised_guard_locks_facing() -> void:
	var runner: GdUnitSceneRunner = scene_runner(PLAYER_SCENE)
	var player: Player = await _hold(runner, "move_back", "block")
	var forward: Vector3 = CombatGeometry.forward_of(player)
	assert_bool(player.guard.is_raised()).is_true()
	assert_float(forward.dot(Vector3.FORWARD)).is_greater(0.95)
