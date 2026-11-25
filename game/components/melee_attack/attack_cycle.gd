class_name AttackCycle
extends RefCounted
## Regra pura do ciclo de um ataque corpo a corpo, sem dependência da árvore de cena: fases
## (preparo, golpe, recuperação) e intervalo até o próximo ataque.

enum Phase { IDLE, WINDUP, ACTIVE, RECOVERY }

## Fase atual do ataque (`IDLE` = sem ataque em curso).
var phase: Phase = Phase.IDLE

var _data: AttackData
var _elapsed: float = 0.0
var _cooldown_left: float = 0.0


## Cria o ciclo parado e livre para atacar, com as fases e o ritmo de `data`.
func _init(data: AttackData) -> void:
	_data = data


## Devolve a fase de um ataque `elapsed` segundos depois do início (`IDLE` depois do fim).
static func phase_at(data: AttackData, elapsed: float) -> Phase:
	if elapsed < data.windup:
		return Phase.WINDUP
	if elapsed < data.windup + data.active:
		return Phase.ACTIVE
	if elapsed < data.get_duration():
		return Phase.RECOVERY
	return Phase.IDLE


## Devolve se um ataque pode começar agora: nenhum em curso e intervalo cumprido.
func can_start() -> bool:
	return phase == Phase.IDLE and _cooldown_left <= 0.0


## Começa um ataque, se possível, e conta o intervalo até o próximo a partir de agora.
## Devolve se começou.
func start() -> bool:
	if not can_start():
		return false
	_elapsed = 0.0
	_cooldown_left = _data.get_cooldown()
	phase = phase_at(_data, _elapsed)
	return true


## Avança `delta` segundos: consome o intervalo e atualiza a fase do ataque em curso.
func tick(delta: float) -> void:
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)
	if phase == Phase.IDLE:
		return
	_elapsed += delta
	phase = phase_at(_data, _elapsed)


## Interrompe o ataque em curso; o intervalo até o próximo continua contando.
func cancel() -> void:
	phase = Phase.IDLE


## Recomeça o intervalo até o próximo ataque a partir de agora, multiplicado por `scale`
## (0,5 depois de um parry perfeito).
func restart_cooldown(scale: float = 1.0) -> void:
	_cooldown_left = _data.get_cooldown() * scale


## Devolve os segundos que faltam para poder atacar de novo.
func get_cooldown_left() -> float:
	return _cooldown_left
