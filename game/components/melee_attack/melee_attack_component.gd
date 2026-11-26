class_name MeleeAttackComponent
extends Node
## Ataque corpo a corpo de uma entidade (regras em `AttackCycle`). Roda as fases do ataque e
## mantém a `HitBox` ligada só durante a fase de golpe.

signal attack_started
signal phase_changed(phase: int)
## `completed` é false quando o ataque foi interrompido por `cancel`.
signal attack_finished(completed: bool)

@export var data: AttackData
@export var hit_box: HitBox

var _cycle: AttackCycle


## Cria o ciclo. Sem `data` atribuído, avisa e usa valores padrão.
func _ready() -> void:
	if data == null:
		push_warning("%s: MeleeAttackComponent sem data; usando valores padrão." % get_path())
		data = AttackData.new()
	if hit_box == null:
		push_warning(
			"%s: MeleeAttackComponent sem hit_box; o golpe não acerta ninguém." % get_path()
		)
	_cycle = AttackCycle.new(data)


## Avança o ataque e, quando a fase muda, sincroniza a HitBox e emite os sinais.
func _physics_process(delta: float) -> void:
	var before: AttackCycle.Phase = _cycle.phase
	_cycle.tick(delta)
	if _cycle.phase == before:
		return
	_sync_hit_box()
	phase_changed.emit(_cycle.phase)
	if _cycle.phase == AttackCycle.Phase.IDLE:
		attack_finished.emit(true)


## Começa um ataque se nenhum estiver em curso e o intervalo já passou; emite `attack_started` e
## `phase_changed`. Devolve se começou.
func try_attack() -> bool:
	if not _cycle.start():
		return false
	_sync_hit_box()
	attack_started.emit()
	phase_changed.emit(_cycle.phase)
	return true


## Interrompe o ataque em curso (o intervalo continua contando) e emite `phase_changed` e
## `attack_finished(false)`. Sem efeito se não houver ataque.
func cancel() -> void:
	if not is_attacking():
		return
	_cycle.cancel()
	_sync_hit_box()
	phase_changed.emit(_cycle.phase)
	attack_finished.emit(false)


## Recomeça o intervalo até o próximo ataque a partir de agora, multiplicado por `scale`.
func restart_cooldown(scale: float = 1.0) -> void:
	_cycle.restart_cooldown(scale)


## Devolve se há um ataque em curso (qualquer fase além de `IDLE`).
func is_attacking() -> bool:
	return _cycle.phase != AttackCycle.Phase.IDLE


## Devolve se o ataque está na fase de golpe (a HitBox está ligada).
func is_in_active_phase() -> bool:
	return _cycle.phase == AttackCycle.Phase.ACTIVE


## Devolve a fase atual (`AttackCycle.Phase`).
func get_phase() -> AttackCycle.Phase:
	return _cycle.phase


## Devolve os segundos que faltam para poder atacar de novo.
func get_cooldown_left() -> float:
	return _cycle.get_cooldown_left()


## Liga a HitBox na fase de golpe e a desliga fora dela.
func _sync_hit_box() -> void:
	if hit_box == null:
		return
	if is_in_active_phase() and not hit_box.is_enabled():
		hit_box.enable(data)
	elif not is_in_active_phase() and hit_box.is_enabled():
		hit_box.disable()
