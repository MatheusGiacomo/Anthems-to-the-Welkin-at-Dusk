extends GdUnitTestSuite
## Regras do animador: prioridade entre situações, locomoção pela direção do movimento e
## velocidade de reprodução.

const FACING: Vector3 = Vector3(0.0, 0.0, -1.0)


func _animations() -> AnimationSet:
	var animations: AnimationSet = AnimationSet.new()
	animations.idle_speed = 0.2
	animations.run_threshold = 3.0
	animations.walk_reference_speed = 2.0
	animations.run_reference_speed = 5.0
	return animations


func _state(velocity: Vector3 = Vector3.ZERO) -> AnimationState:
	var state: AnimationState = AnimationState.new()
	state.velocity = velocity
	state.facing = FACING
	return state


func _pick(state: AnimationState) -> AnimationRules.Clip:
	return AnimationRules.pick(state, _animations())


func test_death_wins_over_everything() -> void:
	var state: AnimationState = _state(FACING * 5.0)
	state.dead = true
	state.staggered = true
	state.attacking = true
	assert_int(_pick(state)).is_equal(AnimationRules.Clip.DEATH)


func test_stagger_wins_over_attack_and_guard() -> void:
	var state: AnimationState = _state()
	state.staggered = true
	state.attacking = true
	state.guarding = true
	assert_int(_pick(state)).is_equal(AnimationRules.Clip.STAGGER)


func test_attack_wins_over_movement() -> void:
	var state: AnimationState = _state(FACING * 5.0)
	state.attacking = true
	assert_int(_pick(state)).is_equal(AnimationRules.Clip.ATTACK)


func test_drawing_then_shot_then_guard() -> void:
	var state: AnimationState = _state()
	state.drawing = true
	state.guarding = true
	assert_int(_pick(state)).is_equal(AnimationRules.Clip.AIM)
	state.drawing = false
	state.recently_shot = true
	assert_int(_pick(state)).is_equal(AnimationRules.Clip.SHOOT)
	state.recently_shot = false
	assert_int(_pick(state)).is_equal(AnimationRules.Clip.GUARD)
	state.guard_hit = true
	assert_int(_pick(state)).is_equal(AnimationRules.Clip.GUARD_HIT)


func test_guard_while_moving_keeps_legs_on_locomotion() -> void:
	var cases: Dictionary[Vector3, AnimationRules.Clip] = {
		FACING * 1.8: AnimationRules.Clip.WALK,
		-FACING * 1.8: AnimationRules.Clip.WALK_BACKWARD,
		Vector3.RIGHT * 1.5: AnimationRules.Clip.STRAFE_RIGHT,
		Vector3.LEFT * 1.5: AnimationRules.Clip.STRAFE_LEFT,
	}
	for velocity: Vector3 in cases:
		var state: AnimationState = _state(velocity)
		state.guarding = true
		assert_int(_pick(state)).is_equal(cases[velocity])
		assert_bool(AnimationRules.has_overlay(state)).is_true()
		assert_int(AnimationRules.overlay_clip(state)).is_equal(AnimationRules.Clip.GUARD)


func test_guard_hit_while_moving_goes_to_the_upper_layer() -> void:
	var state: AnimationState = _state(FACING * 1.8)
	state.guarding = true
	state.guard_hit = true
	assert_int(_pick(state)).is_equal(AnimationRules.Clip.WALK)
	assert_int(AnimationRules.overlay_clip(state)).is_equal(AnimationRules.Clip.GUARD_HIT)


func test_overlay_needs_guard_and_yields_to_higher_priorities() -> void:
	assert_bool(AnimationRules.has_overlay(_state(FACING * 1.8))).is_false()
	for flag: String in ["dead", "staggered", "attacking", "drawing", "recently_shot"]:
		var state: AnimationState = _state(FACING * 1.8)
		state.guarding = true
		state.set(flag, true)
		assert_bool(AnimationRules.has_overlay(state)).override_failure_message(flag).is_false()


func test_locomotion_by_direction_and_speed() -> void:
	assert_int(_pick(_state())).is_equal(AnimationRules.Clip.IDLE)
	assert_int(_pick(_state(FACING * 0.1))).is_equal(AnimationRules.Clip.IDLE)
	assert_int(_pick(_state(FACING * 2.0))).is_equal(AnimationRules.Clip.WALK)
	assert_int(_pick(_state(FACING * 5.0))).is_equal(AnimationRules.Clip.RUN)
	assert_int(_pick(_state(-FACING * 3.0))).is_equal(AnimationRules.Clip.WALK_BACKWARD)
	assert_int(_pick(_state(Vector3.RIGHT * 3.0))).is_equal(AnimationRules.Clip.STRAFE_RIGHT)
	assert_int(_pick(_state(Vector3.LEFT * 3.0))).is_equal(AnimationRules.Clip.STRAFE_LEFT)


func test_diagonal_forward_counts_as_forward() -> void:
	var diagonal: Vector3 = (FACING + Vector3.RIGHT * 0.5).normalized() * 5.0
	assert_int(_pick(_state(diagonal))).is_equal(AnimationRules.Clip.RUN)


func test_attack_clip_is_fitted_to_attack_duration() -> void:
	var state: AnimationState = _state()
	state.attack_duration = 0.5
	var speed: float = AnimationRules.playback_speed(
		AnimationRules.Clip.ATTACK, state, _animations(), 1.0
	)
	assert_float(speed).is_equal_approx(2.0, 0.001)


func test_aim_clip_is_fitted_to_draw_duration() -> void:
	var state: AnimationState = _state()
	state.draw_duration = 2.0
	var speed: float = AnimationRules.playback_speed(
		AnimationRules.Clip.AIM, state, _animations(), 1.0
	)
	assert_float(speed).is_equal_approx(0.5, 0.001)


func test_locomotion_speed_follows_real_speed() -> void:
	var walk: float = AnimationRules.playback_speed(
		AnimationRules.Clip.WALK, _state(FACING * 1.0), _animations(), 1.0
	)
	var run: float = AnimationRules.playback_speed(
		AnimationRules.Clip.RUN, _state(FACING * 5.0), _animations(), 1.0
	)
	assert_float(walk).is_equal_approx(0.5, 0.001)
	assert_float(run).is_equal_approx(1.0, 0.001)


func test_invalid_durations_play_at_normal_speed() -> void:
	var state: AnimationState = _state()
	state.attack_duration = 0.0
	var speed: float = AnimationRules.playback_speed(
		AnimationRules.Clip.ATTACK, state, _animations(), 1.0
	)
	assert_float(speed).is_equal_approx(1.0, 0.001)
