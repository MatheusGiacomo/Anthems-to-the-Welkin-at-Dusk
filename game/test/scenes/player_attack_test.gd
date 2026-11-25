extends GdUnitTestSuite
## Golpe do player num capanga parado à frente: tira vida e o deixa vulnerável.

const HENCHMAN_SCENE: String = "res://enemies/henchman/henchman.tscn"
## Preparo (0,15 s) e golpe (0,15 s) cabem com folga em 30 quadros de física (0,5 s).
const ATTACK_PHYSICS_FRAMES: int = 30


func test_player_attack_damages_and_staggers_enemy() -> void:
	var root: Node3D = auto_free(CombatTestArena.build(HENCHMAN_SCENE, Vector3(0.0, 0.0, -1.5)))
	var runner: GdUnitSceneRunner = scene_runner(root)
	var enemy: Enemy = root.get_child(1) as Enemy
	var full_health: float = enemy.health.max_health
	await CombatTestArena.await_physics_frames(get_tree(), 2)
	runner.simulate_action_press("attack")
	await CombatTestArena.await_physics_frames(get_tree(), ATTACK_PHYSICS_FRAMES)
	runner.simulate_action_release("attack")
	# sword_slash.tres tira 20 de vida e enche o medidor (100 pontos).
	assert_float(enemy.health.current_health).is_between(full_health - 21.0, full_health - 19.0)
	assert_bool(enemy.vulnerability.is_vulnerable()).is_true()
	assert_bool(enemy.is_aggressive()).is_true()
