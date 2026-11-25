extends GdUnitTestSuite
## Regras do empurrão: velocidade inicial, queda linear e fração pelo resultado do golpe.

const DISTANCE: float = 0.6
const DURATION: float = 0.15


func test_linear_decay_covers_the_distance() -> void:
	var start_speed: float = KnockbackRules.initial_speed(DISTANCE, DURATION)
	var steps: int = 100
	var step: float = DURATION / steps
	var covered: float = 0.0
	for index: int in steps:
		covered += KnockbackRules.speed_at(start_speed, (index + 0.5) * step, DURATION) * step
	assert_float(covered).is_equal_approx(DISTANCE, 0.001)


func test_speed_reaches_zero_at_the_end() -> void:
	var start_speed: float = KnockbackRules.initial_speed(DISTANCE, DURATION)
	assert_float(KnockbackRules.speed_at(start_speed, 0.0, DURATION)).is_equal(start_speed)
	assert_float(KnockbackRules.speed_at(start_speed, DURATION, DURATION)).is_equal(0.0)
	assert_float(KnockbackRules.speed_at(start_speed, DURATION * 2.0, DURATION)).is_equal(0.0)


func test_no_distance_or_duration_means_no_push() -> void:
	assert_float(KnockbackRules.initial_speed(0.0, DURATION)).is_equal(0.0)
	assert_float(KnockbackRules.initial_speed(DISTANCE, 0.0)).is_equal(0.0)


func test_hit_pushes_fully_and_guard_pushes_a_fraction() -> void:
	var blocked: float = 0.5
	assert_float(KnockbackRules.outcome_scale(HitResolver.Outcome.HIT, blocked)).is_equal(1.0)
	for outcome: HitResolver.Outcome in [
		HitResolver.Outcome.BLOCKED,
		HitResolver.Outcome.GUARD_BROKEN,
		HitResolver.Outcome.REFLECTED,
	]:
		assert_float(KnockbackRules.outcome_scale(outcome, blocked)).is_equal(blocked)


func test_parry_clash_and_ignored_do_not_push() -> void:
	for outcome: HitResolver.Outcome in [
		HitResolver.Outcome.PARRIED,
		HitResolver.Outcome.CLASHED,
		HitResolver.Outcome.IGNORED,
	]:
		assert_float(KnockbackRules.outcome_scale(outcome, 0.5)).is_equal(0.0)
