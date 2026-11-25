class_name CombatTestArena
extends RefCounted
## Monta, para os testes de cena, um player e um inimigo frente a frente sem chão nem câmera: os
## corpos flutuam e o player olha para -Z.

const PLAYER_SCENE: String = "res://player/player.tscn"


## Devolve uma raiz com o player na origem e o inimigo de `enemy_scene` em `enemy_position`,
## virado para o player. O player fica em `root.get_child(0)` e o inimigo em `get_child(1)`.
static func build(enemy_scene: String, enemy_position: Vector3) -> Node3D:
	var root: Node3D = Node3D.new()
	var player: Player = (load(PLAYER_SCENE) as PackedScene).instantiate() as Player
	var enemy: Enemy = (load(enemy_scene) as PackedScene).instantiate() as Enemy
	root.add_child(player)
	root.add_child(enemy)
	enemy.position = enemy_position
	enemy.rotation.y = CombatGeometry.yaw_for_direction(-enemy_position.normalized())
	return root


## Espera `frames` quadros de física (independe da taxa de quadros da tela).
static func await_physics_frames(tree: SceneTree, frames: int) -> void:
	for frame: int in frames:
		await tree.physics_frame
