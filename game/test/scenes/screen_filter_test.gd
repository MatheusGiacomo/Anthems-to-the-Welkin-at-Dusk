extends GdUnitTestSuite
## Filtro de tela: cobre a tela inteira abaixo da UI, não captura o mouse e aplica o filme
## depois do dithering, sobre uma cópia da tela já pontilhada.

const SCREEN_FILTER_SCENE: String = "res://filters/screen_filter.tscn"
# A UI do jogo (painel de debug, escurecimento) usa camadas a partir de 1.
const FIRST_UI_LAYER: int = 1

var _filter: CanvasLayer


func before_test() -> void:
	var scene: PackedScene = load(SCREEN_FILTER_SCENE) as PackedScene
	_filter = auto_free(scene.instantiate() as CanvasLayer)
	add_child(_filter)


func test_draws_below_game_ui() -> void:
	assert_int(_filter.layer).is_less(FIRST_UI_LAYER)


func test_passes_cover_screen_without_catching_mouse() -> void:
	await get_tree().process_frame
	var screen_size: Vector2 = _filter.get_viewport().get_visible_rect().size
	for pass_name: String in ["Dither", "OldFilm"]:
		var rect: ColorRect = _filter.get_node(pass_name) as ColorRect
		assert_object(rect).is_not_null()
		assert_int(rect.mouse_filter).is_equal(Control.MOUSE_FILTER_IGNORE)
		assert_vector(rect.size).is_equal(screen_size)
		var material: ShaderMaterial = rect.material as ShaderMaterial
		assert_object(material).is_not_null()
		assert_object(material.shader).is_not_null()


func test_film_reads_copy_of_dithered_screen() -> void:
	var dither: Node = _filter.get_node("Dither")
	var copy: BackBufferCopy = _filter.get_node("BackBufferCopy") as BackBufferCopy
	var film: Node = _filter.get_node("OldFilm")
	assert_object(copy).is_not_null()
	assert_int(copy.copy_mode).is_equal(BackBufferCopy.COPY_MODE_VIEWPORT)
	assert_bool(dither.get_index() < copy.get_index()).is_true()
	assert_bool(copy.get_index() < film.get_index()).is_true()
