extends GdUnitTestSuite
## Fluxo das fases: a saída começa fechada, abre sem inimigos vivos e o player nela leva à
## próxima fase.

const SEQUENCE_SCENE: String = "res://levels/level_sequence.tscn"
## Mais que o escurecimento e o clarear (0,4 s cada) com folga, em quadros de física.
const TRANSITION_PHYSICS_FRAMES: int = 120


## Mata todos os inimigos vivos do encontro de `level`.
func _kill_all_enemies(level: Level) -> void:
	for child: Node in level.encounter.get_children():
		var enemy: Enemy = child as Enemy
		if enemy != null and not enemy.health.is_dead():
			enemy.health.damage(enemy.health.max_health)


func test_exit_opens_after_enemies_die_and_leads_to_next_level() -> void:
	var runner: GdUnitSceneRunner = scene_runner(SEQUENCE_SCENE)
	var sequence: LevelSequence = runner.scene() as LevelSequence
	await CombatTestArena.await_physics_frames(get_tree(), 2)
	var level: Level = sequence.current_level
	assert_int(sequence.current_index).is_equal(0)
	assert_bool(level.exit.is_open()).is_false()
	_kill_all_enemies(level)
	await CombatTestArena.await_physics_frames(get_tree(), 2)
	assert_bool(level.exit.is_open()).is_true()
	# Logo depois da barreira, dentro da área de chegada.
	sequence.player.global_position = level.exit.global_position + Vector3(1.5, 0.0, 0.0)
	for frame: int in TRANSITION_PHYSICS_FRAMES:
		if sequence.current_index == 1:
			break
		await get_tree().physics_frame
	assert_int(sequence.current_index).is_equal(1)
	assert_bool(sequence.current_level.exit.is_open()).is_false()
