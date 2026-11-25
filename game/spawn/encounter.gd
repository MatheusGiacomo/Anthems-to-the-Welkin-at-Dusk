class_name Encounter
extends Node3D
## Encontro de inimigos: spawna um inimigo em cada `SpawnPoint` filho, deixa-o agressivo contra o
## alvo (ao aparecer, por proximidade ou ao ser atingido) e conta os vivos. Os inimigos e os
## projéteis deles ficam como filhos deste nó.

signal enemy_spawned(enemy: Enemy)
signal all_enemies_died

## Alvo dos inimigos (o player); atribuído pela cena que usa o encontro. Nulo desliga a agressão
## por proximidade.
@export var target: Node3D

var _alive: Array[Enemy] = []
var _aggro_radius: Dictionary[Enemy, float] = {}


## Deixa agressivo o inimigo parado cujo alvo entrou no raio de agressão do ponto dele.
func _physics_process(_delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return
	for enemy: Enemy in _alive:
		var radius: float = _aggro_radius.get(enemy, 0.0)
		if enemy.is_aggressive() or radius <= 0.0:
			continue
		var distance: float = (
			CombatGeometry.flatten(target.global_position - enemy.global_position).length()
		)
		if distance <= radius:
			enemy.aggro(target)


## Spawna um inimigo em cada `SpawnPoint` filho que tenha cena.
func spawn_all() -> void:
	for child: Node in get_children():
		var point: SpawnPoint = child as SpawnPoint
		if point != null and point.enemy_scene != null:
			_spawn(point)


## Remove todos os inimigos e projéteis do encontro (sem emitir `all_enemies_died`).
func clear() -> void:
	for child: Node in get_children():
		if not child is SpawnPoint:
			child.queue_free()
	_alive.clear()
	_aggro_radius.clear()


## Remove tudo e spawna de novo (o reinício do encontro para testes de balanceamento).
func respawn_all() -> void:
	clear()
	spawn_all()


## Faz todos os inimigos largarem o alvo e desliga a agressão por proximidade.
func calm_all() -> void:
	target = null
	for enemy: Enemy in _alive:
		enemy.calm()


## Devolve quantos inimigos do encontro estão vivos.
func get_alive_count() -> int:
	return _alive.size()


## Instancia o inimigo de `point` (nomeado `<ponto>Enemy`), coloca-o parado no lugar e na
## direção do ponto e registra o raio de agressão. Fica agressivo na hora se o ponto pedir.
func _spawn(point: SpawnPoint) -> void:
	var enemy: Enemy = point.enemy_scene.instantiate() as Enemy
	if enemy == null:
		push_warning("%s: a cena do SpawnPoint não tem Enemy na raiz." % point.get_path())
		return
	# O nome do ponto identifica o inimigo no painel de debug e na árvore remota.
	enemy.name = "%sEnemy" % point.name
	add_child(enemy, true)
	var facing: Basis = Basis(Vector3.UP, point.global_rotation.y)
	enemy.spawn(Transform3D(facing, point.global_position))
	enemy.set_projectile_parent(self)
	enemy.died.connect(_on_enemy_died)
	_alive.append(enemy)
	_aggro_radius[enemy] = point.aggro_radius
	enemy_spawned.emit(enemy)
	if point.aggro_on_spawn and target != null:
		enemy.aggro(target)


## Tira o inimigo morto da contagem e avisa quando não sobra nenhum.
func _on_enemy_died(enemy: Enemy) -> void:
	_alive.erase(enemy)
	_aggro_radius.erase(enemy)
	if _alive.is_empty():
		all_enemies_died.emit()
