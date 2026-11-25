class_name Player
extends CharacterBody3D
## Player controlado por WASD e mouse. Lê o input e orquestra os componentes; as regras ficam
## neles e em `MovementRules`.

@export var config: PlayerConfig

## Câmera usada no movimento relativo à tela e na mira pelo mouse; atribuída pela arena.
## Sem câmera, "para frente" é -Z e o olhar não muda.
var camera: IsometricCamera

@onready var locomotion: LocomotionComponent = $Locomotion


## Sem `config` atribuído, avisa e usa os valores padrão.
func _ready() -> void:
	if config == null:
		push_warning("%s: Player sem config; usando valores padrão." % get_path())
		config = PlayerConfig.new()


## Atualiza o olhar pelo mouse e o movimento pelo teclado.
func _physics_process(delta: float) -> void:
	_update_facing(delta)
	_update_movement(delta)


## Gira o player para o ponto do chão sob o cursor.
func _update_facing(delta: float) -> void:
	if camera == null:
		return
	var aim_point: Vector3 = camera.mouse_ground_point(global_position.y, global_position)
	locomotion.face_direction(aim_point - global_position, delta)


## Move na direção do input, relativa à câmera, com a velocidade dada pelo alinhamento entre o
## movimento e o olhar.
func _update_movement(delta: float) -> void:
	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var camera_yaw: float = camera.get_yaw() if camera != null else 0.0
	var direction: Vector3 = MovementRules.camera_relative_direction(input, camera_yaw)
	var multiplier: float = MovementRules.alignment_multiplier(
		direction, locomotion.get_forward(), config.forward_multiplier, config.backward_multiplier
	)
	locomotion.move(direction * config.move_speed * multiplier, delta)
