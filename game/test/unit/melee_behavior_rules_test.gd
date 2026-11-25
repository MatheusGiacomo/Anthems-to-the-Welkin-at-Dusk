extends GdUnitTestSuite
## Regras do combate corpo a corpo dos inimigos: troca de modo pela distância, tabela de decisão
## depois da investida, saída da vulnerabilidade, movimento na cautela e avanço da investida.

const X: float = 6.0
const HYSTERESIS: float = 0.5
const Y: float = 2.5
const TOLERANCE: float = 0.75
const REACH: float = 1.4
const MAX_LUNGE: float = 4.0


func _config() -> MeleeBehaviorConfig:
	var config: MeleeBehaviorConfig = MeleeBehaviorConfig.new()
	config.approach_distance = X
	config.distance_hysteresis = HYSTERESIS
	config.caution_distance = Y
	config.caution_tolerance = TOLERANCE
	config.strike_reach = REACH
	config.max_lunge_distance = MAX_LUNGE
	return config


func _mode_from(current: MeleeBehaviorRules.Mode, distance: float) -> MeleeBehaviorRules.Mode:
	return MeleeBehaviorRules.distance_mode(current, distance, _config())


func _after_lunge(result: MeleeBehaviorRules.LungeResult, distance: float) -> int:
	return MeleeBehaviorRules.after_lunge(result, distance, _config())


func test_chase_turns_into_caution_at_x() -> void:
	assert_int(_mode_from(MeleeBehaviorRules.Mode.CHASE, X + 0.1)).is_equal(
		MeleeBehaviorRules.Mode.CHASE
	)
	assert_int(_mode_from(MeleeBehaviorRules.Mode.CHASE, X)).is_equal(
		MeleeBehaviorRules.Mode.CAUTION
	)


func test_caution_follows_until_beyond_x_plus_hysteresis() -> void:
	assert_int(_mode_from(MeleeBehaviorRules.Mode.CAUTION, X + HYSTERESIS - 0.1)).is_equal(
		MeleeBehaviorRules.Mode.CAUTION
	)
	assert_int(_mode_from(MeleeBehaviorRules.Mode.CAUTION, X + HYSTERESIS + 0.1)).is_equal(
		MeleeBehaviorRules.Mode.CHASE
	)


func test_hitting_target_lunges_again_even_if_far() -> void:
	assert_int(_after_lunge(MeleeBehaviorRules.LungeResult.HIT_TARGET, Y + 1.0)).is_equal(
		MeleeBehaviorRules.Mode.LUNGE
	)


func test_blocked_or_clashed_lunge_goes_to_caution_even_if_close() -> void:
	assert_int(_after_lunge(MeleeBehaviorRules.LungeResult.BLOCKED, Y - 1.0)).is_equal(
		MeleeBehaviorRules.Mode.CAUTION
	)
	assert_int(_after_lunge(MeleeBehaviorRules.LungeResult.CLASHED, Y - 1.0)).is_equal(
		MeleeBehaviorRules.Mode.CAUTION
	)


func test_missed_lunge_depends_on_distance_to_y() -> void:
	assert_int(_after_lunge(MeleeBehaviorRules.LungeResult.NONE, Y - 0.1)).is_equal(
		MeleeBehaviorRules.Mode.LUNGE
	)
	assert_int(_after_lunge(MeleeBehaviorRules.LungeResult.NONE, Y + 0.1)).is_equal(
		MeleeBehaviorRules.Mode.CAUTION
	)


func test_after_stagger_is_caution_when_near_and_chase_when_far() -> void:
	assert_int(MeleeBehaviorRules.after_stagger(Y, _config())).is_equal(
		MeleeBehaviorRules.Mode.CAUTION
	)
	assert_int(MeleeBehaviorRules.after_stagger(X + HYSTERESIS + 1.0, _config())).is_equal(
		MeleeBehaviorRules.Mode.CHASE
	)


func test_caution_move_advances_strafes_and_retreats() -> void:
	var config: MeleeBehaviorConfig = _config()
	assert_int(MeleeBehaviorRules.caution_move(Y + TOLERANCE + 0.1, config)).is_equal(
		MeleeBehaviorRules.CautionMove.ADVANCE
	)
	assert_int(MeleeBehaviorRules.caution_move(Y + TOLERANCE * 0.5, config)).is_equal(
		MeleeBehaviorRules.CautionMove.STRAFE
	)
	assert_int(MeleeBehaviorRules.caution_move(Y - 0.1, config)).is_equal(
		MeleeBehaviorRules.CautionMove.RETREAT
	)


func test_closer_than_y_still_counts_toward_lunge() -> void:
	var config: MeleeBehaviorConfig = _config()
	assert_bool(MeleeBehaviorRules.counts_toward_lunge(Y - 1.0, config)).is_true()
	assert_bool(MeleeBehaviorRules.counts_toward_lunge(Y + TOLERANCE, config)).is_true()
	assert_bool(MeleeBehaviorRules.counts_toward_lunge(Y + TOLERANCE + 0.1, config)).is_false()


func test_lunge_stops_at_strike_reach_and_is_limited() -> void:
	var config: MeleeBehaviorConfig = _config()
	assert_float(MeleeBehaviorRules.lunge_distance(3.0, config)).is_equal_approx(3.0 - REACH, 0.001)
	assert_float(MeleeBehaviorRules.lunge_distance(20.0, config)).is_equal_approx(MAX_LUNGE, 0.001)
	assert_float(MeleeBehaviorRules.lunge_distance(1.0, config)).is_equal_approx(0.0, 0.001)
