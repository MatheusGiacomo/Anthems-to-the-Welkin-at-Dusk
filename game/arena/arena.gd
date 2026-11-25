class_name Arena
extends Node3D
## Cena principal do MVP V1: arena plana e fechada. Liga o player à câmera e ao encontro de
## inimigos, que spawna ao abrir.

@onready var player: Player = $Player
@onready var camera: IsometricCamera = $IsometricCamera
@onready var encounter: Encounter = $Encounter


## Entrega a câmera ao player, dá o player como alvo do encontro e spawna os inimigos.
func _ready() -> void:
	player.camera = camera
	encounter.target = player
	encounter.spawn_all()


## F5 (`debug_respawn_enemies`) remove os inimigos e spawna de novo.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_respawn_enemies"):
		encounter.respawn_all()
