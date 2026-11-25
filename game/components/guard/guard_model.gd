class_name GuardModel
extends RefCounted
## Regra pura de um escudo, sem dependência da árvore de cena: erguer e abaixar, vida, quebra,
## recarga, tempo até erguer de novo e janela de parry perfeito.

enum LowerReason { RELEASED, BROKEN, INTERRUPTED }

## Vida atual do escudo.
var health: float = 0.0
## Se o escudo está erguido agora.
var is_raised: bool = false
## Se houve parry perfeito na erguida que terminou por último (vale a partir de `lower`).
var last_lowered_after_perfect: bool = false

var _config: GuardConfig
var _lockout: float = 0.0
var _raised_time: float = 0.0
var _perfect_parry_pending: bool = false


## Cria o escudo abaixado, com a vida cheia e livre para erguer.
func _init(config: GuardConfig) -> void:
	_config = config
	health = config.max_health


## Devolve se o escudo pode ser erguido agora: abaixado e fora do tempo de espera.
func can_raise() -> bool:
	return not is_raised and _lockout <= 0.0


## Ergue o escudo, se possível, e reinicia a janela de parry. Devolve se ergueu.
func raise() -> bool:
	if not can_raise():
		return false
	is_raised = true
	_raised_time = 0.0
	return true


## Abaixa o escudo. Quebra espera `broken_lockout` para erguer de novo; os outros motivos,
## `release_lockout`. Atualiza `last_lowered_after_perfect`. Sem efeito se já estava abaixado.
func lower(reason: LowerReason) -> void:
	if not is_raised:
		return
	is_raised = false
	if reason == LowerReason.BROKEN:
		_lockout = _config.broken_lockout
	else:
		_lockout = _config.release_lockout
	last_lowered_after_perfect = _perfect_parry_pending
	_perfect_parry_pending = false


## Devolve se um golpe defendido agora contaria como parry perfeito.
func is_in_perfect_window() -> bool:
	return is_raised and _config.perfect_window > 0.0 and _raised_time <= _config.perfect_window


## Devolve se um golpe com `guard_damage` quebraria o escudo erguido.
func would_break(guard_damage: float) -> bool:
	return _config.breakable and health - guard_damage <= 0.0


## Absorve um golpe defendido: tira `guard_damage` da vida (se quebrável) e registra o parry se
## `perfect`. Se a vida zerar, abaixa por quebra. Devolve se quebrou.
func absorb(guard_damage: float, perfect: bool) -> bool:
	if not is_raised:
		return false
	if perfect:
		_perfect_parry_pending = true
	if not _config.breakable:
		return false
	health = maxf(health - guard_damage, 0.0)
	if health > 0.0:
		return false
	lower(LowerReason.BROKEN)
	return true


## Avança `delta` segundos: erguido, conta o tempo da janela de parry; abaixado, consome o tempo
## de espera e recarrega a vida proporcionalmente a `full_regen_time`.
func tick(delta: float) -> void:
	if is_raised:
		_raised_time += delta
		return
	_lockout = maxf(_lockout - delta, 0.0)
	if _config.full_regen_time <= 0.0:
		health = _config.max_health
		return
	var regen_rate: float = _config.max_health / _config.full_regen_time
	health = minf(health + regen_rate * delta, _config.max_health)


## Devolve os segundos que faltam para poder erguer de novo.
func get_lockout_left() -> float:
	return _lockout
