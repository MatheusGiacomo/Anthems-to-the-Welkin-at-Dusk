class_name FixedCamera
extends Camera3D
## Câmera ortográfica parada que enquadra uma área inteira da cena (`frame`). O zoom se ajusta à
## proporção da janela e é refeito quando ela muda de tamanho.

## Inclinação para baixo, em graus (90 = vista de cima).
@export var pitch_degrees: float = 45.0
## Giro em torno do eixo vertical, em graus (0 = olhando para -Z, "norte" para cima na tela).
@export var yaw_degrees: float = 0.0
## Metros entre a câmera e o centro da área, ao longo da linha de visão.
@export var distance: float = 60.0
## Folga, em metros, entre a área e as bordas da tela.
@export var margin: float = 1.0

var _bounds: AABB = AABB()
var _has_bounds: bool = false


## Configura a projeção e o ângulo e passa a refazer o enquadramento quando a janela muda.
func _ready() -> void:
	projection = PROJECTION_ORTHOGONAL
	keep_aspect = KEEP_HEIGHT
	rotation = Vector3(deg_to_rad(-pitch_degrees), deg_to_rad(yaw_degrees), 0.0)
	get_viewport().size_changed.connect(_refit)


## Centraliza a câmera em `bounds` (área do mundo) e ajusta o zoom para mostrá-la inteira.
func frame(bounds: AABB) -> void:
	_bounds = bounds
	_has_bounds = true
	_refit()


## Devolve o giro da câmera em Y (radianos), para o movimento relativo à tela.
func get_yaw() -> float:
	return rotation.y


## Recalcula posição e zoom para a área atual, com a proporção atual da janela.
func _refit() -> void:
	if not _has_bounds:
		return
	var screen: Vector2 = get_viewport().get_visible_rect().size
	var aspect: float = screen.x / screen.y if screen.y > 0.0 else 1.0
	var view_basis: Basis = Basis.from_euler(rotation)
	size = CameraFraming.fit_size(_bounds, view_basis, aspect, margin)
	position = _bounds.get_center() + view_basis.z * distance
