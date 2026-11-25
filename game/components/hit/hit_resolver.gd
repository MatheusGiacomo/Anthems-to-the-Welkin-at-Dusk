class_name HitResolver
extends RefCounted
## Regra pura que decide o resultado de um golpe a partir do ataque e do estado do defensor.
## Ordem: choque de espadas, depois defesa pelo escudo, senão acerto.

enum Outcome { HIT, BLOCKED, PARRIED, GUARD_BROKEN, REFLECTED, CLASHED, IGNORED }


## Devolve o resultado do golpe `attack` contra o defensor descrito em `defense`:
## - `CLASHED`: o defensor está de frente e no golpe do próprio ataque, e o ataque pode trombar;
## - `REFLECTED`: defendido por uma guarda que reflete (o atacante fica atordoado);
## - `PARRIED`: defendido na janela de parry, se o ataque for aparável (o atacante fica atordoado);
## - `GUARD_BROKEN` ou `BLOCKED`: defendido, quebrando ou não o escudo;
## - `HIT`: nenhum dos casos acima.
static func resolve(attack: AttackData, defense: DefenseState) -> Outcome:
	if attack.can_clash and defense.attacking_active and defense.facing_attacker:
		return Outcome.CLASHED
	if not (attack.blockable and defense.guard_raised and defense.guard_covers):
		return Outcome.HIT
	if defense.guard_reflects:
		return Outcome.REFLECTED
	if attack.parryable and defense.guard_perfect:
		return Outcome.PARRIED
	if defense.guard_would_break:
		return Outcome.GUARD_BROKEN
	return Outcome.BLOCKED


## Devolve se o resultado é um golpe defendido pelo escudo (sem dano nem vulnerabilidade).
static func is_blocked(outcome: Outcome) -> bool:
	return outcome in [Outcome.BLOCKED, Outcome.PARRIED, Outcome.GUARD_BROKEN, Outcome.REFLECTED]
