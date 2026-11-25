class_name DebugOverlay
extends CanvasLayer
## Painel de balanceamento: vida, vulnerabilidade, escudo e ataque do player e inimigos vivos.
## F3 (`debug_toggle_overlay`) mostra ou esconde o painel e os rótulos sobre os inimigos.

## Atribuído pela arena.
var player: Player
## Atribuído pela arena.
var encounter: Encounter

@onready var _text: Label = %Text


## Alinha os rótulos dos inimigos à visibilidade inicial do painel.
func _ready() -> void:
	EnemyDebugLabel.shown = visible


## Alterna o painel e os rótulos no F3.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_toggle_overlay"):
		visible = not visible
		EnemyDebugLabel.shown = visible


## Atualiza o texto enquanto visível.
func _process(_delta: float) -> void:
	if visible and player != null and is_instance_valid(player):
		_text.text = _describe()


## Devolve o texto do painel com o estado atual do player e do encontro.
func _describe() -> String:
	var lines: PackedStringArray = ["F3 painel · F5 reaparecer inimigos", ""]
	lines.append("vida %.0f / %.0f" % [player.health.current_health, player.health.max_health])
	var vulnerability: VulnerabilityComponent = player.vulnerability
	var stunned: String = ""
	if vulnerability.is_vulnerable():
		stunned = "  ATORDOADO %.2f s" % vulnerability.get_remaining()
	lines.append(
		(
			"vulnerabilidade %.0f / %.0f%s"
			% [vulnerability.get_meter(), vulnerability.config.threshold, stunned]
		)
	)
	lines.append(_describe_guard(player.guard))
	var sword: MeleeAttackComponent = player.sword
	var phase: String = str(AttackCycle.Phase.keys()[sword.get_phase()])
	lines.append("ataque %s  intervalo %.2f s" % [phase, sword.get_cooldown_left()])
	if encounter != null:
		lines.append("")
		lines.append("inimigos vivos %d" % encounter.get_alive_count())
	return "\n".join(lines)


## Devolve a linha do escudo: vida, se está erguido (e na janela de parry) ou o tempo de espera.
func _describe_guard(guard: GuardComponent) -> String:
	var state: String = "abaixado"
	if guard.is_raised():
		state = "ERGUIDO (parry)" if guard.is_in_perfect_window() else "ERGUIDO"
	elif guard.get_lockout_left() > 0.0:
		state = "espera %.2f s" % guard.get_lockout_left()
	return "escudo %.0f / %.0f  %s" % [guard.get_health(), guard.config.max_health, state]
