class_name Arena
extends Node3D
## Cena principal do MVP V1: arena plana e fechada. Liga o player à câmera.

@onready var player: Player = $Player
@onready var camera: IsometricCamera = $IsometricCamera


## Entrega a câmera ao player (movimento relativo à tela e mira pelo mouse).
func _ready() -> void:
	player.camera = camera
