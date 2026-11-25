extends GdUnitTestSuite
## Regras do escudo: tempos para erguer de novo, vida, quebra, parry perfeito e recarga.

const ARROW_GUARD_DAMAGE: float = 35.0
const MELEE_GUARD_DAMAGE: float = 100.0


func _make_config() -> GuardConfig:
	var config: GuardConfig = GuardConfig.new()
	config.max_health = 100.0
	config.breakable = true
	config.full_regen_time = 1.5
	config.broken_lockout = 1.5
	config.release_lockout = 0.5
	config.perfect_window = 0.5
	return config


func _make_raised_guard(config: GuardConfig = _make_config()) -> GuardModel:
	var guard: GuardModel = GuardModel.new(config)
	guard.raise()
	return guard


func test_raise_fails_while_raised() -> void:
	var guard: GuardModel = _make_raised_guard()
	assert_bool(guard.is_raised).is_true()
	assert_bool(guard.raise()).is_false()


func test_release_waits_release_lockout() -> void:
	var guard: GuardModel = _make_raised_guard()
	guard.lower(GuardModel.LowerReason.RELEASED)
	assert_bool(guard.can_raise()).is_false()
	guard.tick(0.45)
	assert_bool(guard.can_raise()).is_false()
	guard.tick(0.1)
	assert_bool(guard.raise()).is_true()


func test_melee_hit_breaks_guard_at_once() -> void:
	var guard: GuardModel = _make_raised_guard()
	assert_bool(guard.would_break(MELEE_GUARD_DAMAGE)).is_true()
	assert_bool(guard.absorb(MELEE_GUARD_DAMAGE, false)).is_true()
	assert_bool(guard.is_raised).is_false()


func test_three_arrows_break_guard() -> void:
	var guard: GuardModel = _make_raised_guard()
	assert_bool(guard.absorb(ARROW_GUARD_DAMAGE, false)).is_false()
	assert_bool(guard.absorb(ARROW_GUARD_DAMAGE, false)).is_false()
	assert_bool(guard.is_raised).is_true()
	assert_bool(guard.absorb(ARROW_GUARD_DAMAGE, false)).is_true()
	assert_bool(guard.is_raised).is_false()


func test_broken_guard_waits_broken_lockout() -> void:
	var guard: GuardModel = _make_raised_guard()
	guard.absorb(MELEE_GUARD_DAMAGE, false)
	guard.tick(1.4)
	assert_bool(guard.can_raise()).is_false()
	guard.tick(0.15)
	assert_bool(guard.can_raise()).is_true()
	assert_float(guard.health).is_equal_approx(100.0, 0.001)


func test_perfect_window_lasts_from_raise() -> void:
	var guard: GuardModel = _make_raised_guard()
	assert_bool(guard.is_in_perfect_window()).is_true()
	guard.tick(0.45)
	assert_bool(guard.is_in_perfect_window()).is_true()
	guard.tick(0.1)
	assert_bool(guard.is_in_perfect_window()).is_false()


func test_perfect_parry_is_reported_on_lower() -> void:
	var guard: GuardModel = _make_raised_guard()
	guard.absorb(MELEE_GUARD_DAMAGE, true)
	assert_bool(guard.last_lowered_after_perfect).is_true()
	guard.tick(2.0)
	guard.raise()
	guard.lower(GuardModel.LowerReason.RELEASED)
	assert_bool(guard.last_lowered_after_perfect).is_false()


func test_lowered_guard_regenerates_proportionally() -> void:
	var guard: GuardModel = _make_raised_guard()
	guard.absorb(ARROW_GUARD_DAMAGE, false)
	guard.absorb(ARROW_GUARD_DAMAGE, false)
	guard.lower(GuardModel.LowerReason.RELEASED)
	guard.tick(0.45)
	assert_float(guard.health).is_equal_approx(60.0, 0.001)


func test_raised_guard_does_not_regenerate() -> void:
	var guard: GuardModel = _make_raised_guard()
	guard.absorb(ARROW_GUARD_DAMAGE, false)
	guard.tick(1.0)
	assert_float(guard.health).is_equal_approx(65.0, 0.001)


func test_unbreakable_guard_never_breaks() -> void:
	var config: GuardConfig = _make_config()
	config.breakable = false
	var guard: GuardModel = _make_raised_guard(config)
	assert_bool(guard.would_break(MELEE_GUARD_DAMAGE)).is_false()
	assert_bool(guard.absorb(MELEE_GUARD_DAMAGE, false)).is_false()
	assert_bool(guard.is_raised).is_true()
	assert_float(guard.health).is_equal_approx(100.0, 0.001)
