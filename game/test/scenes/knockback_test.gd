extends GdUnitTestSuite
## Empurrão na cena: o golpe do player afasta o capanga atingido.

const HENCHMAN_SCENE: String = "res://enemies/henchman/henchman.tscn"
const START_DISTANCE: float = 1.5
## Preparo e golpe (0,3 s) mais o empurrão (0,15 s) cabem com folga em 45 quadros de física.
const ATTACK_PHYSICS_FRAMES: int = 45


func test_player_hit_pushes_the_enemy_back() -> void:
	var start: Vector3 = Vector3(0.0, 0.0, -START_DISTANCE)
	var root: Node3D = auto_free(CombatTestArena.build(HENCHMAN_SCENE, start))
	var runner: GdUnitSceneRunner = scene_runner(root)
	var enemy: Enemy = root.get_child(1) as Enemy
	await CombatTestArena.await_physics_frames(get_tree(), 2)
	runner.simulate_action_press("attack")
	await CombatTestArena.await_physics_frames(get_tree(), ATTACK_PHYSICS_FRAMES)
	runner.simulate_action_release("attack")
	var pushed: float = CombatGeometry.flatten(enemy.global_position).length() - START_DISTANCE
	# sword_slash.tres empurra 0,6 m.
	assert_float(pushed).is_between(0.4, 0.8)
