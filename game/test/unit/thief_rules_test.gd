extends GdUnitTestSuite
## Regras do ladrão: aproximação e tiro pela distância, sorteio entre fuga e luta, volta à
## distância de tiro e avanço enquanto mira.

const X: float = 10.0
const TOLERANCE: float = 1.5
const HYSTERESIS: float = 0.5
const FIGHT_CHANCE: float = 0.5


func _config() -> RangedBehaviorConfig:
	var config: RangedBehaviorConfig = RangedBehaviorConfig.new()
	config.attack_distance = X
	config.distance_tolerance = TOLERANCE
	config.distance_hysteresis = HYSTERESIS
	config.fight_chance = FIGHT_CHANCE
	return config


func test_chase_turns_into_shooting_at_x() -> void:
	assert_int(ThiefRules.distance_mode(ThiefRules.Mode.CHASE, X + 0.1, _config())).is_equal(
		ThiefRules.Mode.CHASE
	)
	assert_int(ThiefRules.distance_mode(ThiefRules.Mode.CHASE, X, _config())).is_equal(
		ThiefRules.Mode.SHOOT
	)


func test_shooting_keeps_until_beyond_x_plus_hysteresis() -> void:
	var config: RangedBehaviorConfig = _config()
	assert_int(ThiefRules.distance_mode(ThiefRules.Mode.SHOOT, X + 0.4, config)).is_equal(
		ThiefRules.Mode.SHOOT
	)
	assert_int(ThiefRules.distance_mode(ThiefRules.Mode.SHOOT, X + 0.6, config)).is_equal(
		ThiefRules.Mode.CHASE
	)


func test_near_after_stagger_raffles_fight_or_flee() -> void:
	var config: RangedBehaviorConfig = _config()
	assert_int(ThiefRules.after_stagger(X - 1.0, config, FIGHT_CHANCE - 0.1)).is_equal(
		ThiefRules.Mode.FIGHT
	)
	assert_int(ThiefRules.after_stagger(X - 1.0, config, FIGHT_CHANCE + 0.1)).is_equal(
		ThiefRules.Mode.FLEE
	)


func test_far_after_stagger_does_not_raffle() -> void:
	var config: RangedBehaviorConfig = _config()
	assert_int(ThiefRules.after_stagger(X, config, 0.0)).is_equal(ThiefRules.Mode.SHOOT)
	assert_int(ThiefRules.after_stagger(X + 5.0, config, 0.0)).is_equal(ThiefRules.Mode.CHASE)


func test_back_at_range_from_x() -> void:
	assert_bool(ThiefRules.is_back_at_range(X - 0.1, _config())).is_false()
	assert_bool(ThiefRules.is_back_at_range(X, _config())).is_true()


func test_advances_while_aiming_only_beyond_x_minus_tolerance() -> void:
	var config: RangedBehaviorConfig = _config()
	assert_bool(ThiefRules.advances_while_aiming(X - TOLERANCE + 0.1, config)).is_true()
	assert_bool(ThiefRules.advances_while_aiming(X - TOLERANCE - 0.1, config)).is_false()
