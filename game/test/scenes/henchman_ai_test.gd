extends GdUnitTestSuite
## IA do capanga: agressivo e longe do player, corre até ele e entra na cautela a cerca de X.

const HENCHMAN_SCENE: String = "res://enemies/henchman/henchman.tscn"
const START_DISTANCE: float = 15.0
## A 5,5 m/s, os 9 m até X = 6 levam cerca de 1,7 s; 2,5 s de física dão folga sem chegar à
## investida (a cautela só conta tempo a até 3,25 m).
const WAIT_PHYSICS_FRAMES: int = 150


func test_aggressive_henchman_approaches_and_turns_cautious() -> void:
	var root: Node3D = auto_free(
		CombatTestArena.build(HENCHMAN_SCENE, Vector3(0.0, 0.0, -START_DISTANCE))
	)
	scene_runner(root)
	var player: Player = root.get_child(0) as Player
	var enemy: Enemy = root.get_child(1) as Enemy
	await CombatTestArena.await_physics_frames(get_tree(), 2)
	enemy.aggro(player)
	assert_str(str(enemy.brain.get_state_name())).is_equal("Chase")
	await CombatTestArena.await_physics_frames(get_tree(), WAIT_PHYSICS_FRAMES)
	var distance: float = (
		CombatGeometry.flatten(enemy.global_position - player.global_position).length()
	)
	assert_str(str(enemy.brain.get_state_name())).is_equal("Caution")
	assert_float(distance).is_between(3.0, 6.5)
