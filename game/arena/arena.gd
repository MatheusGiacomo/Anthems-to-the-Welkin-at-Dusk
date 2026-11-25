class_name Arena
extends Node3D
## Arena de teste: plana e fechada, com a câmera fixa enquadrando tudo. Liga o player à câmera,
## ao encontro de inimigos (que spawna ao abrir) e ao painel de debug, e reinicia a arena quando o
## player morre.

## Segundos entre a morte do player e o reinício da arena.
@export var restart_delay: float = 1.5
## Área do mundo que a câmera enquadra (o chão da arena).
@export var view_bounds: AABB = AABB(Vector3(-20.0, 0.0, -20.0), Vector3(40.0, 2.0, 40.0))

@onready var player: Player = $Player
@onready var camera: FixedCamera = $FixedCamera
@onready var encounter: Encounter = $Encounter
@onready var debug_overlay: DebugOverlay = $DebugOverlay


## Enquadra a arena, entrega a câmera ao player, dá o player como alvo do encontro, liga o painel
## de debug, spawna os inimigos e passa a ouvir a morte do player.
func _ready() -> void:
	camera.frame(view_bounds)
	player.camera = camera
	encounter.target = player
	debug_overlay.player = player
	debug_overlay.encounter = encounter
	encounter.spawn_all()
	player.died.connect(_on_player_died)


## F5 (`debug_respawn_enemies`) remove os inimigos e spawna de novo.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_respawn_enemies"):
		encounter.respawn_all()


## Acalma os inimigos e, depois de `restart_delay`, recarrega a arena do zero.
func _on_player_died() -> void:
	encounter.calm_all()
	await get_tree().create_timer(restart_delay).timeout
	get_tree().reload_current_scene()
