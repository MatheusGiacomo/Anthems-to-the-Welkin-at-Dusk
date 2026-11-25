extends GdUnitTestSuite
## Enquadramento da câmera fixa: o tamanho ortográfico que mostra uma área inteira.

const TOP_DOWN: Basis = Basis(Vector3.RIGHT, deg_to_rad(-90.0))


## Área de `width` × `depth` metros no chão, centrada na origem.
func _area(width: float, depth: float) -> AABB:
	return AABB(Vector3(-width * 0.5, 0.0, -depth * 0.5), Vector3(width, 0.0, depth))


func test_wide_area_is_limited_by_width() -> void:
	# Vista de cima, 40 m de largura numa tela 2:1 pedem 20 m de altura visível.
	var size: float = CameraFraming.fit_size(_area(40.0, 10.0), TOP_DOWN, 2.0, 0.0)
	assert_float(size).is_equal_approx(20.0, 0.001)


func test_deep_area_is_limited_by_height() -> void:
	var size: float = CameraFraming.fit_size(_area(10.0, 30.0), TOP_DOWN, 2.0, 0.0)
	assert_float(size).is_equal_approx(30.0, 0.001)


func test_margin_is_added_to_each_edge() -> void:
	var size: float = CameraFraming.fit_size(_area(10.0, 30.0), TOP_DOWN, 2.0, 1.0)
	assert_float(size).is_equal_approx(32.0, 0.001)


func test_tilted_view_shortens_the_depth() -> void:
	# Inclinada a 30°, a profundidade aparece multiplicada por sen(30°) = 0,5.
	var tilted: Basis = Basis(Vector3.RIGHT, deg_to_rad(-30.0))
	var size: float = CameraFraming.fit_size(_area(4.0, 20.0), tilted, 1.0, 0.0)
	assert_float(size).is_equal_approx(10.0, 0.001)
