class_name CameraFraming
extends RefCounted
## Regras puras do enquadramento de uma câmera ortográfica fixa.


## Devolve o tamanho ortográfico (altura visível, em metros, como `Camera3D.size` com
## `KEEP_HEIGHT`) que mostra a caixa `bounds` inteira, vista por uma câmera com a orientação
## `view_basis`, numa tela de proporção `aspect` (largura / altura), com `margin` metros de folga
## em cada borda. A câmera deve estar centrada no centro da caixa.
static func fit_size(bounds: AABB, view_basis: Basis, aspect: float, margin: float) -> float:
	var to_view: Basis = view_basis.orthonormalized().transposed()
	var center: Vector3 = bounds.get_center()
	var half_width: float = 0.0
	var half_height: float = 0.0
	for index: int in 8:
		var corner: Vector3 = to_view * (bounds.get_endpoint(index) - center)
		half_width = maxf(half_width, absf(corner.x))
		half_height = maxf(half_height, absf(corner.y))
	var height: float = (half_height + margin) * 2.0
	var width: float = (half_width + margin) * 2.0
	if aspect <= 0.0:
		return height
	return maxf(height, width / aspect)
