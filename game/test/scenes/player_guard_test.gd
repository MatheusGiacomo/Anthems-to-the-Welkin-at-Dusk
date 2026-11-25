extends GdUnitTestSuite
## Investida do capanga contra o escudo erguido do player: o escudo defende e o player não perde
## vida.

const HENCHMAN_SCENE: String = "res://enemies/henchman/henchman.tscn"
## Cautela (1,5 s) + preparo da investida (0,8 s) + folga: até 4 s de física.
const MAX_WAIT_PHYSICS_FRAMES: int = 240


func test_raised_guard_blocks_henchman_lunge() -> void:
	var root: Node3D = auto_free(CombatTestArena.build(HENCHMAN_SCENE, Vector3(0.0, 0.0, -2.5)))
	var runner: GdUnitSceneRunner = scene_runner(root)
	var player: Player = root.get_child(0) as Player
	var enemy: Enemy = root.get_child(1) as Enemy
	var blocks: Array[int] = [0]
	player.guard.blocked.connect(func(_perfect: bool, _broke: bool) -> void: blocks[0] += 1)
	runner.simulate_action_press("block")
	await CombatTestArena.await_physics_frames(get_tree(), 2)
	enemy.aggro(player)
	var lost_presses: int = 0
	for frame: int in MAX_WAIT_PHYSICS_FRAMES:
		# Se a janela de teste perde o foco, o Godot solta as ações pressionadas; o escudo
		# precisa continuar erguido para o teste medir a defesa, não o foco da janela.
		if not Input.is_action_pressed("block"):
			lost_presses += 1
			Input.action_press("block")
		# Sem câmera o player não mira: vira-o para o capanga, que circula na cautela.
		var to_enemy: Vector3 = CombatGeometry.direction_on_ground(
			player.global_position, enemy.global_position
		)
		player.rotation.y = CombatGeometry.yaw_for_direction(to_enemy)
		await get_tree().physics_frame
		if blocks[0] > 0:
			break
	runner.simulate_action_release("block")
	Input.action_release("block")
	var context: String = "defesas %d, botão solto %d vez(es)" % [blocks[0], lost_presses]
	assert_int(blocks[0]).override_failure_message(context).is_equal(1)
	assert_float(player.health.current_health).is_equal_approx(player.health.max_health, 0.001)
