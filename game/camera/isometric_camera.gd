class_name IsometricCamera
extends Camera3D
## Câmera ortográfica isométrica que segue um alvo e projeta o cursor do mouse no chão.

## Nó seguido pela câmera (o player); atribuído pela cena que a usa.
@export var target: Node3D
## Inclinação para baixo, em graus. 35,264° é o ângulo do isométrico verdadeiro.
@export var pitch_degrees: float = 35.264
## Giro em torno do eixo vertical, em graus.
@export var yaw_degrees: float = 45.0
## Metros entre a câmera e o alvo, ao longo da linha de visão.
@export var distance: float = 30.0
## Altura visível, em metros (zoom da projeção ortográfica).
@export var view_size: float = 18.0
## Rapidez com que a câmera alcança o alvo (0 = cola no alvo).
@export var follow_speed: float = 8.0


## Configura a projeção e o ângulo e já começa sobre o alvo.
func _ready() -> void:
	projection = PROJECTION_ORTHOGONAL
	size = view_size
	rotation = Vector3(deg_to_rad(-pitch_degrees), deg_to_rad(yaw_degrees), 0.0)
	if target != null:
		global_position = _desired_position()


## Segue o alvo no mesmo ritmo da física, para o movimento do player não tremer na tela.
func _physics_process(delta: float) -> void:
	if target == null:
		return
	if follow_speed <= 0.0:
		global_position = _desired_position()
		return
	var weight: float = 1.0 - exp(-follow_speed * delta)
	global_position = global_position.lerp(_desired_position(), weight)


## Devolve o giro da câmera em Y (radianos), para o movimento relativo à tela.
func get_yaw() -> float:
	return rotation.y


## Devolve o ponto do plano horizontal de altura `height` sob o cursor do mouse, ou `fallback`
## se o raio não cruzar o plano.
func mouse_ground_point(height: float, fallback: Vector3) -> Vector3:
	var mouse: Vector2 = get_viewport().get_mouse_position()
	var ground: Plane = Plane(Vector3.UP, height)
	var hit: Variant = ground.intersects_ray(project_ray_origin(mouse), project_ray_normal(mouse))
	if hit == null:
		return fallback
	return hit as Vector3


## Devolve a posição que mantém o alvo no centro da tela, a `distance` metros dele.
func _desired_position() -> Vector3:
	return target.global_position + global_basis.z * distance
