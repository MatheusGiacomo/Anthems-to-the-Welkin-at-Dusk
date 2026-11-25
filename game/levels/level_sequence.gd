class_name LevelSequence
extends Node3D
## Cena principal: carrega as fases em ordem. Põe o player no início de cada uma, enquadra a
## câmera nela e liga o painel de debug. Quando o player sai pela saída aberta, escurece a tela,
## troca para a próxima fase (depois da última, volta à primeira) e clareia. Quando o player morre,
## recomeça a fase atual do mesmo jeito.

signal level_loaded(index: int)

## Fases, na ordem em que são jogadas.
@export var levels: Array[PackedScene] = []
## Cena do player, instanciada de novo a cada fase (com vida cheia).
@export var player_scene: PackedScene
## Índice da fase em que o jogo começa.
@export var start_index: int = 0
## Segundos entre a morte do player e o escurecimento.
@export var restart_delay: float = 1.0

var current_level: Level
var current_index: int = -1
var player: Player

# Impede começar uma segunda troca de fase no meio de uma.
var _transitioning: bool = false

@onready var camera: FixedCamera = $FixedCamera
@onready var fade: ScreenFade = $ScreenFade
@onready var debug_overlay: DebugOverlay = $DebugOverlay
@onready var _level_slot: Node3D = $LevelSlot


## Começa com a tela preta, carrega a fase inicial e clareia.
func _ready() -> void:
	if levels.is_empty() or player_scene == null:
		push_warning("%s: LevelSequence sem fases ou sem player_scene." % get_path())
		return
	fade.set_black()
	load_level(start_index)
	await fade.fade_in()


## F5 (`debug_respawn_enemies`) reaparece os inimigos da fase atual e fecha a saída dela.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_respawn_enemies") and current_level != null:
		current_level.respawn_enemies()


## Troca na hora a fase atual pela de índice `index` (dá a volta na lista), com um player novo no
## início dela, e emite `level_loaded`.
func load_level(index: int) -> void:
	if current_level != null:
		_level_slot.remove_child(current_level)
		current_level.queue_free()
	current_index = wrapi(index, 0, levels.size())
	current_level = levels[current_index].instantiate() as Level
	_level_slot.add_child(current_level)
	player = player_scene.instantiate() as Player
	current_level.add_child(player)
	player.global_transform = current_level.get_player_start()
	player.camera = camera
	player.died.connect(_on_player_died)
	current_level.exit_reached.connect(_on_level_exit_reached)
	current_level.start(player)
	camera.frame(current_level.view_bounds)
	debug_overlay.player = player
	debug_overlay.encounter = current_level.encounter
	level_loaded.emit(current_index)


## Escurece, troca para a fase `index` e clareia. Ignorado se já houver uma troca em curso.
func _transition_to(index: int) -> void:
	if _transitioning:
		return
	_transitioning = true
	player.set_physics_process(false)
	await fade.fade_out()
	load_level(index)
	await fade.fade_in()
	_transitioning = false


## O player saiu pela saída aberta: vai para a próxima fase.
func _on_level_exit_reached() -> void:
	_transition_to(current_index + 1)


## O player morreu: os inimigos o largam e, depois de `restart_delay`, a fase recomeça.
func _on_player_died() -> void:
	current_level.calm()
	await get_tree().create_timer(restart_delay).timeout
	_transition_to(current_index)
