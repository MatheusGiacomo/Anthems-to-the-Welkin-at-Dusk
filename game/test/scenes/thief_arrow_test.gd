extends GdUnitTestSuite
## Tiro do ladrão: a flecha voa até o player e o escudo erguido a defende (desgaste de 35, sem
## parry e sem perda de vida).

const THIEF_SCENE: String = "res://enemies/thief/thief.tscn"
## Mira (1 s) + puxada (1 s) + voo de cerca de 0,5 s + folga: até 4 s de física.
const MAX_WAIT_PHYSICS_FRAMES: int = 240


func test_raised_guard_blocks_arrow() -> void:
	var root: Node3D = auto_free(CombatTestArena.build(THIEF_SCENE, Vector3(0.0, 0.0, -9.0)))
	var runner: GdUnitSceneRunner = scene_runner(root)
	var player: Player = root.get_child(0) as Player
	var enemy: Enemy = root.get_child(1) as Enemy
	var blocks: Array[bool] = []
	player.guard.blocked.connect(func(perfect: bool, _broke: bool) -> void: blocks.append(perfect))
	runner.simulate_action_press("block")
	await CombatTestArena.await_physics_frames(get_tree(), 2)
	enemy.aggro(player)
	for frame: int in MAX_WAIT_PHYSICS_FRAMES:
		await get_tree().physics_frame
		if not blocks.is_empty():
			break
	runner.simulate_action_release("block")
	assert_array(blocks).is_equal([false])
	assert_float(player.guard.get_health()).is_between(60.0, 70.0)
	assert_float(player.health.current_health).is_equal_approx(player.health.max_health, 0.001)
