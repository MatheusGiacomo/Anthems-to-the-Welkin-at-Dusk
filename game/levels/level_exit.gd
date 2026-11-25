class_name LevelExit
extends Node3D
## Saída de uma fase: uma barreira que impede a passagem enquanto está fechada e, logo depois
## dela (em +X local), uma área que avisa quando o player chega. A abertura tem `opening_width`
## metros ao longo de Z local.

signal player_entered

## Largura da passagem, em metros (ao longo de Z local).
@export var opening_width: float = 6.0
## Profundidade da área de chegada, em metros (ao longo de +X local, depois da barreira).
@export var trigger_depth: float = 2.0

var _open: bool = false

@onready var _barrier: StaticBody3D = $Barrier
@onready var _barrier_shape: CollisionShape3D = $Barrier/CollisionShape3D
@onready var _barrier_mesh: MeshInstance3D = $Barrier/Mesh
@onready var _trigger: Area3D = $Trigger
@onready var _trigger_shape: CollisionShape3D = $Trigger/CollisionShape3D


## Dimensiona barreira e área pela largura da passagem, começa fechada e passa a ouvir o player.
func _ready() -> void:
	var barrier_size: Vector3 = Vector3(0.6, 3.0, opening_width)
	var barrier_box: BoxShape3D = BoxShape3D.new()
	barrier_box.size = barrier_size
	_barrier_shape.shape = barrier_box
	var barrier_mesh: BoxMesh = _barrier_mesh.mesh.duplicate() as BoxMesh
	barrier_mesh.size = barrier_size
	_barrier_mesh.mesh = barrier_mesh
	var trigger_box: BoxShape3D = BoxShape3D.new()
	trigger_box.size = Vector3(trigger_depth, 3.0, opening_width)
	_trigger_shape.shape = trigger_box
	_trigger.position = Vector3(trigger_depth * 0.5 + 0.5, 1.5, 0.0)
	_trigger.body_entered.connect(_on_trigger_body_entered)
	close()


## Abre a passagem: tira a barreira (colisão e visual).
func open() -> void:
	_open = true
	_barrier_shape.set_deferred("disabled", true)
	_barrier.visible = false


## Fecha a passagem com a barreira.
func close() -> void:
	_open = false
	_barrier_shape.set_deferred("disabled", false)
	_barrier.visible = true


## Devolve se a passagem está aberta.
func is_open() -> bool:
	return _open


## Avisa `player_entered` quando o player entra na área com a passagem aberta.
func _on_trigger_body_entered(body: Node3D) -> void:
	if _open and body is Player:
		player_entered.emit()
