extends GdUnitTestSuite
## Aplicação do resultado de um golpe pela HurtBox nos componentes do defensor e da HitBox no
## atacante, sem física: os golpes são entregues chamando os métodos diretamente.

const DAMAGE: float = 20.0
const VULNERABILITY_POINTS: float = 100.0
const GUARD_DAMAGE: float = 35.0
## A HurtBox olha para -Z: um golpe vindo da frente viaja em +Z.
const FROM_FRONT: Vector3 = Vector3(0.0, 0.0, 1.0)
const FROM_BEHIND: Vector3 = Vector3(0.0, 0.0, -1.0)

var _health: HealthComponent
var _vulnerability: VulnerabilityComponent
var _guard: GuardComponent
var _hurt_box: HurtBox


func before_test() -> void:
	var defender: Node3D = auto_free(Node3D.new())
	_health = HealthComponent.new()
	_vulnerability = VulnerabilityComponent.new()
	_vulnerability.config = VulnerabilityConfig.new()
	_guard = GuardComponent.new()
	_guard.config = GuardConfig.new()
	_hurt_box = HurtBox.new()
	_hurt_box.health = _health
	_hurt_box.vulnerability = _vulnerability
	_hurt_box.guard = _guard
	for child: Node in [_health, _vulnerability, _guard, _hurt_box]:
		defender.add_child(child)
	add_child(defender)


func _attack() -> AttackData:
	var attack: AttackData = AttackData.new()
	attack.damage = DAMAGE
	attack.vulnerability_points = VULNERABILITY_POINTS
	attack.guard_damage = GUARD_DAMAGE
	return attack


func test_hit_applies_damage_and_vulnerability() -> void:
	var outcome: HitResolver.Outcome = _hurt_box.receive_hit(HitInfo.new(_attack(), FROM_FRONT))
	assert_int(outcome).is_equal(HitResolver.Outcome.HIT)
	assert_float(_health.current_health).is_equal_approx(100.0 - DAMAGE, 0.001)
	assert_bool(_vulnerability.is_vulnerable()).is_true()


func test_block_spends_guard_and_spares_health() -> void:
	_guard.raise()
	var outcome: HitResolver.Outcome = _hurt_box.receive_hit(HitInfo.new(_attack(), FROM_FRONT))
	assert_int(outcome).is_equal(HitResolver.Outcome.PARRIED)
	assert_float(_health.current_health).is_equal_approx(100.0, 0.001)
	assert_float(_guard.get_health()).is_equal_approx(100.0 - GUARD_DAMAGE, 0.001)
	assert_bool(_vulnerability.is_vulnerable()).is_false()


func test_guard_does_not_cover_the_back() -> void:
	_guard.raise()
	var outcome: HitResolver.Outcome = _hurt_box.receive_hit(HitInfo.new(_attack(), FROM_BEHIND))
	assert_int(outcome).is_equal(HitResolver.Outcome.HIT)
	assert_float(_health.current_health).is_equal_approx(100.0 - DAMAGE, 0.001)


func test_dead_defender_ignores_hits() -> void:
	_health.damage(_health.max_health)
	var outcome: HitResolver.Outcome = _hurt_box.receive_hit(HitInfo.new(_attack(), FROM_FRONT))
	assert_int(outcome).is_equal(HitResolver.Outcome.IGNORED)


func test_parried_attacker_is_stunned() -> void:
	var attacker_vulnerability: VulnerabilityComponent = auto_free(VulnerabilityComponent.new())
	attacker_vulnerability.config = VulnerabilityConfig.new()
	var attacker: Node3D = auto_free(Node3D.new())
	add_child(attacker)
	# À frente do defensor, que olha para -Z.
	attacker.global_position = Vector3(0.0, 0.0, -2.0)
	var hit_box: HitBox = auto_free(HitBox.new())
	hit_box.vulnerability = attacker_vulnerability
	hit_box.source = attacker
	add_child(attacker_vulnerability)
	_guard.raise()
	hit_box.enable(_attack())
	hit_box._strike(_hurt_box)
	assert_bool(attacker_vulnerability.is_vulnerable()).is_true()
	assert_float(attacker_vulnerability.get_remaining()).is_equal_approx(
		attacker_vulnerability.config.parried_duration, 0.001
	)
