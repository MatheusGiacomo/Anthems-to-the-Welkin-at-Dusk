class_name GuardComponent
extends Node
## Escudo ou guarda de uma entidade (regras em `GuardModel`). Quem usa ergue e abaixa; a HurtBox
## consulta o estado e chama `absorb` quando um golpe é defendido.

signal raised
## `reason` é um `GuardModel.LowerReason`; `after_perfect_parry` diz se houve parry perfeito
## nesta erguida (o player usa para cortar pela metade o intervalo do próximo ataque).
signal lowered(reason: int, after_perfect_parry: bool)
signal blocked(perfect: bool, broke: bool)

@export var config: GuardConfig

var _model: GuardModel


## Cria o modelo. Sem `config` atribuído, avisa e usa os valores padrão.
func _ready() -> void:
	if config == null:
		push_warning("%s: GuardComponent sem config; usando valores padrão." % get_path())
		config = GuardConfig.new()
	_model = GuardModel.new(config)


## Avança a janela de parry, o tempo de espera e a recarga.
func _physics_process(delta: float) -> void:
	_model.tick(delta)


## Ergue o escudo se ele estiver livre; emite `raised`. Devolve se ergueu.
func raise() -> bool:
	if not _model.raise():
		return false
	raised.emit()
	return true


## Abaixa o escudo por `reason` (um `GuardModel.LowerReason`) e emite `lowered`. Sem efeito se já
## estava abaixado.
func lower(reason: GuardModel.LowerReason) -> void:
	if not _model.is_raised:
		return
	_model.lower(reason)
	lowered.emit(reason, _model.last_lowered_after_perfect)


## Absorve um golpe defendido e emite `blocked`; se o escudo quebrar, emite também `lowered` com
## o motivo `BROKEN`.
func absorb(guard_damage: float, perfect: bool) -> void:
	var broke: bool = _model.absorb(guard_damage, perfect)
	blocked.emit(perfect, broke)
	if broke:
		lowered.emit(GuardModel.LowerReason.BROKEN, _model.last_lowered_after_perfect)


## Devolve se o escudo está erguido.
func is_raised() -> bool:
	return _model.is_raised


## Devolve se pode erguer agora (abaixado e fora do tempo de espera).
func can_raise() -> bool:
	return _model.can_raise()


## Devolve se um golpe defendido agora contaria como parry perfeito.
func is_in_perfect_window() -> bool:
	return _model.is_in_perfect_window()


## Devolve se um golpe com `guard_damage` quebraria o escudo.
func would_break(guard_damage: float) -> bool:
	return _model.would_break(guard_damage)


## Devolve a vida atual do escudo.
func get_health() -> float:
	return _model.health


## Devolve os segundos que faltam para poder erguer de novo.
func get_lockout_left() -> float:
	return _model.get_lockout_left()
