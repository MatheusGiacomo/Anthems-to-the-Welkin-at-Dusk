extends GdUnitTestSuite
## Regras do ciclo de ataque: fases, intervalo pelo ritmo, cancelamento e intervalo cortado.

const ATTACKS_PER_SECOND: float = 0.7


func _make_data() -> AttackData:
	var data: AttackData = AttackData.new()
	data.windup = 0.15
	data.active = 0.15
	data.recovery = 0.3
	data.attacks_per_second = ATTACKS_PER_SECOND
	return data


func test_cooldown_comes_from_attacks_per_second() -> void:
	assert_float(_make_data().get_cooldown()).is_equal_approx(1.0 / ATTACKS_PER_SECOND, 0.001)


func test_cooldown_is_at_least_the_attack_duration() -> void:
	var data: AttackData = _make_data()
	data.attacks_per_second = 10.0
	assert_float(data.get_cooldown()).is_equal_approx(0.6, 0.001)
	data.attacks_per_second = 0.0
	assert_float(data.get_cooldown()).is_equal_approx(0.6, 0.001)


func test_phases_follow_the_attack_timing() -> void:
	var cycle: AttackCycle = AttackCycle.new(_make_data())
	assert_bool(cycle.start()).is_true()
	assert_int(cycle.phase).is_equal(AttackCycle.Phase.WINDUP)
	cycle.tick(0.2)
	assert_int(cycle.phase).is_equal(AttackCycle.Phase.ACTIVE)
	cycle.tick(0.2)
	assert_int(cycle.phase).is_equal(AttackCycle.Phase.RECOVERY)
	cycle.tick(0.3)
	assert_int(cycle.phase).is_equal(AttackCycle.Phase.IDLE)


func test_next_attack_waits_for_cooldown() -> void:
	var cycle: AttackCycle = AttackCycle.new(_make_data())
	cycle.start()
	cycle.tick(0.7)
	assert_bool(cycle.can_start()).is_false()
	cycle.tick(0.75)
	assert_bool(cycle.start()).is_true()


func test_cancel_stops_attack_but_keeps_cooldown() -> void:
	var cycle: AttackCycle = AttackCycle.new(_make_data())
	cycle.start()
	cycle.tick(0.1)
	cycle.cancel()
	assert_int(cycle.phase).is_equal(AttackCycle.Phase.IDLE)
	assert_bool(cycle.can_start()).is_false()


func test_restart_cooldown_can_be_halved() -> void:
	var cycle: AttackCycle = AttackCycle.new(_make_data())
	cycle.restart_cooldown(0.5)
	assert_float(cycle.get_cooldown_left()).is_equal_approx(0.5 / ATTACKS_PER_SECOND, 0.001)
	cycle.tick(0.5 / ATTACKS_PER_SECOND + 0.01)
	assert_bool(cycle.can_start()).is_true()
