extends GdUnitTestSuite
## Regras da vida: dano limitado a zero e sinal de morte emitido uma única vez.


func _make_health(max_health: float) -> HealthComponent:
	var health: HealthComponent = auto_free(HealthComponent.new())
	health.max_health = max_health
	health.reset()
	return health


func test_damage_reduces_health() -> void:
	var health: HealthComponent = _make_health(100.0)
	health.damage(30.0)
	assert_float(health.current_health).is_equal_approx(70.0, 0.001)
	assert_bool(health.is_dead()).is_false()


func test_health_does_not_go_below_zero() -> void:
	var health: HealthComponent = _make_health(50.0)
	health.damage(80.0)
	assert_float(health.current_health).is_equal_approx(0.0, 0.001)
	assert_bool(health.is_dead()).is_true()


func test_died_is_emitted_once() -> void:
	var health: HealthComponent = _make_health(20.0)
	var deaths: Array[int] = [0]
	health.died.connect(func() -> void: deaths[0] += 1)
	health.damage(20.0)
	health.damage(20.0)
	assert_int(deaths[0]).is_equal(1)


func test_non_positive_damage_is_ignored() -> void:
	var health: HealthComponent = _make_health(20.0)
	health.damage(0.0)
	health.damage(-5.0)
	assert_float(health.current_health).is_equal_approx(20.0, 0.001)
