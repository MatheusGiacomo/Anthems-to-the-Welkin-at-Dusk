class_name EnemyDebugLabel
extends Label3D
## Rótulo de balanceamento sobre um inimigo: estado da IA, vida e medidor de vulnerabilidade.
## Visível enquanto o painel de debug estiver ligado (`shown`).

## Ligado e desligado pelo `DebugOverlay` (F3); vale para todos os rótulos.
static var shown: bool = true

@export var brain: EnemyBrain
@export var health: HealthComponent
@export var vulnerability: VulnerabilityComponent


## Atualiza a visibilidade e, se visível, o texto.
func _process(_delta: float) -> void:
	visible = shown
	if not visible or brain == null or health == null or vulnerability == null:
		return
	text = (
		"%s\nvida %.0f  vuln %.0f%s"
		% [
			brain.get_state_name(),
			health.current_health,
			vulnerability.get_meter(),
			"  ATORDOADO" if vulnerability.is_vulnerable() else "",
		]
	)
