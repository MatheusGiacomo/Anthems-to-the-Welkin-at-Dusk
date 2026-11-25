extends GdUnitTestSuite
## Tabela de resultados de um golpe: acerto, bloqueio, parry, quebra, guarda que reflete e choque.


func _melee() -> AttackData:
	var attack: AttackData = AttackData.new()
	attack.blockable = true
	attack.parryable = true
	attack.can_clash = true
	return attack


func _arrow() -> AttackData:
	var attack: AttackData = AttackData.new()
	attack.blockable = true
	attack.parryable = false
	attack.can_clash = false
	return attack


func _guarding(perfect: bool = false, covers: bool = true) -> DefenseState:
	var defense: DefenseState = DefenseState.new()
	defense.guard_raised = true
	defense.guard_covers = covers
	defense.guard_perfect = perfect
	return defense


func test_undefended_hit() -> void:
	var outcome: HitResolver.Outcome = HitResolver.resolve(_melee(), DefenseState.new())
	assert_int(outcome).is_equal(HitResolver.Outcome.HIT)


func test_guard_in_front_blocks() -> void:
	assert_int(HitResolver.resolve(_melee(), _guarding())).is_equal(HitResolver.Outcome.BLOCKED)


func test_attack_from_outside_the_arc_hits() -> void:
	var outcome: HitResolver.Outcome = HitResolver.resolve(_melee(), _guarding(false, false))
	assert_int(outcome).is_equal(HitResolver.Outcome.HIT)


func test_perfect_timing_parries_melee() -> void:
	var outcome: HitResolver.Outcome = HitResolver.resolve(_melee(), _guarding(true))
	assert_int(outcome).is_equal(HitResolver.Outcome.PARRIED)


func test_parry_wins_over_guard_break() -> void:
	var defense: DefenseState = _guarding(true)
	defense.guard_would_break = true
	assert_int(HitResolver.resolve(_melee(), defense)).is_equal(HitResolver.Outcome.PARRIED)


func test_arrow_is_never_parried() -> void:
	assert_int(HitResolver.resolve(_arrow(), _guarding(true))).is_equal(HitResolver.Outcome.BLOCKED)


func test_hit_that_empties_the_guard_breaks_it() -> void:
	var defense: DefenseState = _guarding()
	defense.guard_would_break = true
	assert_int(HitResolver.resolve(_melee(), defense)).is_equal(HitResolver.Outcome.GUARD_BROKEN)


func test_reflecting_guard_reflects() -> void:
	var defense: DefenseState = _guarding(true)
	defense.guard_reflects = true
	assert_int(HitResolver.resolve(_melee(), defense)).is_equal(HitResolver.Outcome.REFLECTED)


func test_unblockable_attack_ignores_guard() -> void:
	var attack: AttackData = _melee()
	attack.blockable = false
	assert_int(HitResolver.resolve(attack, _guarding())).is_equal(HitResolver.Outcome.HIT)


func test_simultaneous_active_attacks_clash() -> void:
	var defense: DefenseState = DefenseState.new()
	defense.attacking_active = true
	defense.facing_attacker = true
	assert_int(HitResolver.resolve(_melee(), defense)).is_equal(HitResolver.Outcome.CLASHED)


func test_no_clash_when_defender_faces_away() -> void:
	var defense: DefenseState = DefenseState.new()
	defense.attacking_active = true
	defense.facing_attacker = false
	assert_int(HitResolver.resolve(_melee(), defense)).is_equal(HitResolver.Outcome.HIT)


func test_arrow_does_not_clash() -> void:
	var defense: DefenseState = DefenseState.new()
	defense.attacking_active = true
	defense.facing_attacker = true
	assert_int(HitResolver.resolve(_arrow(), defense)).is_equal(HitResolver.Outcome.HIT)


func test_blocked_outcomes() -> void:
	assert_bool(HitResolver.is_blocked(HitResolver.Outcome.PARRIED)).is_true()
	assert_bool(HitResolver.is_blocked(HitResolver.Outcome.REFLECTED)).is_true()
	assert_bool(HitResolver.is_blocked(HitResolver.Outcome.HIT)).is_false()
	assert_bool(HitResolver.is_blocked(HitResolver.Outcome.CLASHED)).is_false()
