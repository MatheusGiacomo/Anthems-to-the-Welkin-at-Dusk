class_name ThiefRules
extends RefCounted
## Regras puras do ladrão: troca entre aproximação e tiro pela distância, sorteio entre fuga e
## luta ao sair da vulnerabilidade, volta à distância de tiro e movimento enquanto mira.

enum Mode { CHASE, SHOOT, FLEE, FIGHT }


## Devolve o modo pela distância, partindo de `current` (`CHASE` ou `SHOOT`): a aproximação vira
## tiro a X; o tiro só volta à aproximação acima de X mais a folga.
static func distance_mode(current: Mode, distance: float, config: RangedBehaviorConfig) -> Mode:
	var near: bool = DistanceHysteresis.is_near(
		current != Mode.CHASE, distance, config.attack_distance, config.distance_hysteresis
	)
	return Mode.SHOOT if near else Mode.CHASE


## Devolve o modo ao sair da vulnerabilidade. Com o alvo ainda perto (mais perto que X), sorteia:
## `roll` (0 a 1) abaixo de `fight_chance` luta com a adaga, senão foge. Longe, segue pela
## distância.
static func after_stagger(distance: float, config: RangedBehaviorConfig, roll: float) -> Mode:
	if distance < config.attack_distance:
		return Mode.FIGHT if roll < config.fight_chance else Mode.FLEE
	return distance_mode(Mode.SHOOT, distance, config)


## Devolve se o ladrão voltou à distância de tiro (fim da fuga e da luta com a adaga).
static func is_back_at_range(distance: float, config: RangedBehaviorConfig) -> bool:
	return distance >= config.attack_distance


## Devolve se, mirando, o ladrão ainda avança devagar (alvo além de X − tolerância).
static func advances_while_aiming(distance: float, config: RangedBehaviorConfig) -> bool:
	return distance > config.attack_distance - config.distance_tolerance
