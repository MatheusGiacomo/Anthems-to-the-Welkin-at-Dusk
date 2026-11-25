extends GdUnitTestSuite
## Encontro de inimigos: spawna parado no lugar de cada ponto, fica agressivo pela proximidade do
## alvo e reaparece.

const HENCHMAN_SCENE: String = "res://enemies/henchman/henchman.tscn"
const AGGRO_RADIUS: float = 5.0

var _encounter: Encounter
var _target: Node3D


func before_test() -> void:
	var root: Node3D = auto_free(Node3D.new())
	_target = Node3D.new()
	root.add_child(_target)
	_target.position = Vector3(50.0, 0.0, 0.0)
	_encounter = Encounter.new()
	root.add_child(_encounter)
	for position: Vector3 in [Vector3(-10.0, 0.0, 0.0), Vector3(10.0, 0.0, 0.0)]:
		var point: SpawnPoint = SpawnPoint.new()
		point.enemy_scene = load(HENCHMAN_SCENE) as PackedScene
		point.aggro_radius = AGGRO_RADIUS
		point.position = position
		_encounter.add_child(point)
	_encounter.target = _target
	add_child(root)


func _enemies() -> Array[Enemy]:
	var enemies: Array[Enemy] = []
	for child: Node in _encounter.get_children():
		if child is Enemy and not child.is_queued_for_deletion():
			enemies.append(child as Enemy)
	return enemies


func test_spawns_idle_enemy_at_each_point() -> void:
	_encounter.spawn_all()
	var enemies: Array[Enemy] = _enemies()
	assert_int(_encounter.get_alive_count()).is_equal(2)
	assert_int(enemies.size()).is_equal(2)
	assert_vector(enemies[0].global_position).is_equal_approx(
		Vector3(-10.0, 0.0, 0.0), Vector3.ONE * 0.01
	)
	assert_bool(enemies[0].is_aggressive()).is_false()
	assert_bool(enemies[1].is_aggressive()).is_false()


func test_target_in_radius_makes_enemy_aggressive() -> void:
	_encounter.spawn_all()
	_target.global_position = Vector3(10.0 + AGGRO_RADIUS - 1.0, 0.0, 0.0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var enemies: Array[Enemy] = _enemies()
	assert_bool(enemies[0].is_aggressive()).is_false()
	assert_bool(enemies[1].is_aggressive()).is_true()


func test_respawn_replaces_enemies() -> void:
	_encounter.spawn_all()
	var first: Array[Enemy] = _enemies()
	_encounter.respawn_all()
	var second: Array[Enemy] = _enemies()
	assert_int(_encounter.get_alive_count()).is_equal(2)
	assert_int(second.size()).is_equal(2)
	assert_bool(second.has(first[0])).is_false()
