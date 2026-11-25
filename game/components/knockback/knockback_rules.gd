class_name KnockbackRules
extends RefCounted
## Regras puras do empurrão de um golpe: a velocidade começa alta e cai linearmente até zero no
## fim da duração, percorrendo a distância pedida.


## Devolve a velocidade inicial, em m/s, que percorre `distance` metros caindo linearmente até
## zero em `duration` segundos. Zero se a distância ou a duração não forem positivas.
static func initial_speed(distance: float, duration: float) -> float:
	if distance <= 0.0 or duration <= 0.0:
		return 0.0
	return 2.0 * distance / duration


## Devolve a velocidade do empurrão `elapsed` segundos depois do início, partindo de
## `start_speed` e chegando a zero em `duration`. Zero fora do intervalo.
static func speed_at(start_speed: float, elapsed: float, duration: float) -> float:
	if duration <= 0.0 or elapsed < 0.0 or elapsed >= duration:
		return 0.0
	return start_speed * (1.0 - elapsed / duration)


## Devolve a fração do empurrão que o defensor sofre pelo resultado do golpe: inteiro no acerto,
## `blocked_scale` quando o escudo defende (inclusive quebrando ou refletindo) e nenhum no parry,
## no choque e no golpe ignorado.
static func outcome_scale(outcome: HitResolver.Outcome, blocked_scale: float) -> float:
	match outcome:
		HitResolver.Outcome.HIT:
			return 1.0
		HitResolver.Outcome.BLOCKED, HitResolver.Outcome.GUARD_BROKEN:
			return blocked_scale
		HitResolver.Outcome.REFLECTED:
			return blocked_scale
	return 0.0
