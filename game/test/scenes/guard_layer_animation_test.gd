extends GdUnitTestSuite
## Animação em camadas: o capanga na cautela anda com as pernas (locomoção na camada de baixo) e
## mantém a guarda no tronco (camada de cima).

const HENCHMAN_SCENE: String = "res://enemies/henchman/henchman.tscn"
## Dentro de X (6 m) e além de Y + tolerância (3,25 m): entra na cautela e avança.
const START_DISTANCE: float = 5.0
## 0,75 s: já na cautela e em movimento, antes de completar `time_to_lunge` perto do alvo.
const WAIT_PHYSICS_FRAMES: int = 45
const LOCOMOTION_CLIPS: Array[AnimationRules.Clip] = [
	AnimationRules.Clip.WALK,
	AnimationRules.Clip.WALK_BACKWARD,
	AnimationRules.Clip.RUN,
	AnimationRules.Clip.STRAFE_LEFT,
	AnimationRules.Clip.STRAFE_RIGHT,
]


func test_cautious_henchman_walks_with_guard_on_upper_body() -> void:
	var root: Node3D = auto_free(
		CombatTestArena.build(HENCHMAN_SCENE, Vector3(0.0, 0.0, -START_DISTANCE))
	)
	scene_runner(root)
	var player: Player = root.get_child(0) as Player
	var enemy: Enemy = root.get_child(1) as Enemy
	var animator: CharacterAnimator = enemy.get_node("Animator") as CharacterAnimator
	await CombatTestArena.await_physics_frames(get_tree(), 2)
	enemy.aggro(player)
	await CombatTestArena.await_physics_frames(get_tree(), WAIT_PHYSICS_FRAMES)
	assert_str(str(enemy.brain.get_state_name())).is_equal("Caution")
	assert_float(CombatGeometry.flatten(enemy.velocity).length()).is_greater(0.5)
	assert_array(LOCOMOTION_CLIPS).contains([animator.get_base_clip()])
	assert_int(animator.get_overlay_clip()).is_equal(AnimationRules.Clip.GUARD)
	assert_float(animator.get_overlay_weight()).is_between(0.9, 1.0)
