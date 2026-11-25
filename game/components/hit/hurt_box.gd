class_name HurtBox
extends Area3D
## Área que recebe golpes de uma entidade. Lê o estado do defensor, resolve o golpe com o
## `HitResolver` e aplica o efeito no próprio defensor: dano e vulnerabilidade, escudo ou choque.
## O efeito no atacante fica com quem deu o golpe (`HitBox`), a partir do resultado devolvido.

signal hit_received(hit: HitInfo, outcome: int)

# Abertura do arco frontal em que o defensor "encara" o atacante para haver choque de espadas.
const CLASH_ARC_DEGREES: float = 120.0

@export var health: HealthComponent
@export var vulnerability: VulnerabilityComponent
## Opcional: sem escudo, nenhum golpe é defendido.
@export var guard: GuardComponent
## Opcional: sem ataque corpo a corpo, não há choque de espadas.
@export var attack: MeleeAttackComponent


## Avisa se faltar uma dependência obrigatória.
func _ready() -> void:
	if health == null or vulnerability == null:
		push_warning("%s: HurtBox sem health ou vulnerability." % get_path())


## Resolve `hit` contra esta entidade, aplica o efeito nela e emite `hit_received`. Devolve o
## `HitResolver.Outcome`; `IGNORED` se a entidade já morreu.
func receive_hit(hit: HitInfo) -> HitResolver.Outcome:
	if health == null or vulnerability == null or health.is_dead():
		return HitResolver.Outcome.IGNORED
	var outcome: HitResolver.Outcome = HitResolver.resolve(hit.attack, _read_defense(hit))
	_apply(hit, outcome)
	hit_received.emit(hit, outcome)
	return outcome


## Devolve o estado do defensor no instante do golpe, com o arco medido a partir da frente
## desta área (que gira com o corpo).
func _read_defense(hit: HitInfo) -> DefenseState:
	var defense: DefenseState = DefenseState.new()
	var forward: Vector3 = CombatGeometry.forward_of(self)
	var to_attacker: Vector3 = -hit.direction
	if guard != null and guard.is_raised():
		defense.guard_raised = true
		defense.guard_covers = CombatGeometry.is_within_arc(
			forward, to_attacker, guard.config.arc_degrees
		)
		defense.guard_perfect = guard.is_in_perfect_window()
		defense.guard_reflects = guard.config.reflects_attacks
		defense.guard_would_break = guard.would_break(hit.attack.guard_damage)
	if attack != null:
		defense.attacking_active = attack.is_in_active_phase()
		defense.facing_attacker = CombatGeometry.is_within_arc(
			forward, to_attacker, CLASH_ARC_DEGREES
		)
	return defense


## Aplica no defensor o efeito do resultado: dano e pontos no acerto, desgaste do escudo na
## defesa, atordoamento no choque. Guarda que reflete não sofre desgaste.
func _apply(hit: HitInfo, outcome: HitResolver.Outcome) -> void:
	match outcome:
		HitResolver.Outcome.HIT:
			health.damage(hit.attack.damage)
			vulnerability.add_points(hit.attack.vulnerability_points)
		HitResolver.Outcome.BLOCKED, HitResolver.Outcome.GUARD_BROKEN:
			guard.absorb(hit.attack.guard_damage, false)
		HitResolver.Outcome.PARRIED:
			guard.absorb(hit.attack.guard_damage, true)
		HitResolver.Outcome.CLASHED:
			vulnerability.stun(vulnerability.config.clash_duration)
