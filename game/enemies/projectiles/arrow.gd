class_name Arrow
extends Node3D
## Flecha com física própria: voa sob gravidade e, a cada passo, testa o trecho percorrido com um
## raio (não atravessa alvos finos em alta velocidade). Ao tocar uma HurtBox, entrega o golpe;
## ao tocar o mundo, ou depois de `lifetime`, some.

## Camadas que o raio testa: mundo e HurtBox do player (sem fogo amigo entre inimigos).
@export_flags_3d_physics var collision_mask: int = 9
## Segundos de voo até sumir sem acertar nada.
@export var lifetime: float = 5.0

var _velocity: Vector3 = Vector3.ZERO
var _gravity: float = 0.0
var _attack: AttackData = null
var _attacker: Node3D = null
var _age: float = 0.0


## Voa um passo: aplica a gravidade, testa o trecho com um raio e acerta, some ou avança.
func _physics_process(delta: float) -> void:
	if _attack == null:
		return
	_age += delta
	if _age >= lifetime:
		queue_free()
		return
	_velocity.y -= _gravity * delta
	var from: Vector3 = global_position
	var to: Vector3 = from + _velocity * delta
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		from, to, collision_mask
	)
	query.collide_with_areas = true
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		_on_impact(hit.get("collider") as Object)
		return
	global_position = to
	_face_velocity()


## Lança a flecha da posição atual com `velocity` (m/s), sob `gravity` (m/s²), carregando os
## efeitos de `attack`; `attacker` é quem atirou.
func launch(velocity: Vector3, gravity: float, attack: AttackData, attacker: Node3D) -> void:
	_velocity = velocity
	_gravity = gravity
	_attack = attack
	_attacker = attacker
	_face_velocity()


## Aponta a flecha na direção do voo.
func _face_velocity() -> void:
	if (
		_velocity.length_squared() > 0.0001
		and not _velocity.normalized().is_equal_approx(Vector3.UP)
	):
		look_at(global_position + _velocity, Vector3.UP)


## Entrega o golpe se tocou uma HurtBox; em qualquer impacto, some.
func _on_impact(collider: Object) -> void:
	var hurt_box: HurtBox = collider as HurtBox
	if hurt_box != null:
		hurt_box.receive_hit(HitInfo.new(_attack, _velocity, _attacker))
	queue_free()
