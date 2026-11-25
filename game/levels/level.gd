class_name Level
extends Node3D
## Uma fase: o player entra por um lado, passa pelos inimigos do encontro e sai pelo outro. A
## saída só abre quando não sobra inimigo vivo. Quem carrega a fase (`LevelSequence`) põe o player
## no início, chama `start` e ouve `exit_reached`.

signal exit_reached

## Área do mundo que a câmera fixa enquadra.
@export var view_bounds: AABB = AABB(Vector3(-22.0, 0.0, -12.0), Vector3(44.0, 2.0, 24.0))

@onready var encounter: Encounter = $Encounter
@onready var exit: LevelExit = $Exit
@onready var _player_start: Marker3D = $PlayerStart


## Liga a abertura da saída ao fim dos inimigos e repassa a chegada do player à saída.
func _ready() -> void:
	encounter.all_enemies_died.connect(_on_encounter_all_enemies_died)
	exit.player_entered.connect(_on_exit_player_entered)


## Começa a fase contra `player`: dá o alvo ao encontro, spawna os inimigos e abre a saída se não
## houver nenhum.
func start(player: Player) -> void:
	encounter.target = player
	encounter.spawn_all()
	_sync_exit()


## Devolve onde o player começa a fase (posição e direção).
func get_player_start() -> Transform3D:
	return _player_start.global_transform


## Remove os inimigos, spawna de novo e fecha a saída (o F5 de teste).
func respawn_enemies() -> void:
	encounter.respawn_all()
	_sync_exit()


## Faz os inimigos largarem o player (na morte dele).
func calm() -> void:
	encounter.calm_all()


## Abre a saída sem inimigos vivos; fecha com algum.
func _sync_exit() -> void:
	if encounter.get_alive_count() == 0:
		exit.open()
	else:
		exit.close()


## O último inimigo morreu: abre a saída.
func _on_encounter_all_enemies_died() -> void:
	exit.open()


## O player chegou à saída aberta: avisa quem carregou a fase.
func _on_exit_player_entered() -> void:
	exit_reached.emit()
