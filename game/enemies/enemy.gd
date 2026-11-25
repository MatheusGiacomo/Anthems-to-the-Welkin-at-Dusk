class_name Enemy
extends CharacterBody3D
## Base dos inimigos: spawn, agressão e morte. O comportamento de combate fica no `EnemyBrain`
## filho (`Brain`); os componentes comuns são `Health`, `Vulnerability` e `HurtBox`.

signal died(enemy: Enemy)

@onready var health: HealthComponent = $Health
@onready var vulnerability: VulnerabilityComponent = $Vulnerability
@onready var hurt_box: HurtBox = $HurtBox
@onready var brain: EnemyBrain = $Brain


## Escuta a morte e os golpes recebidos.
func _ready() -> void:
	health.died.connect(_on_health_died)
	hurt_box.hit_received.connect(_on_hurt_box_hit_received)


## Coloca o inimigo parado em `spawn_transform`, sem alvo. Chame depois de adicioná-lo à árvore.
func spawn(spawn_transform: Transform3D) -> void:
	global_transform = spawn_transform
	velocity = Vector3.ZERO
	brain.calm()


## Define `target` como alvo: o inimigo passa a lutar com a IA dele contra o alvo.
func aggro(target: Node3D) -> void:
	brain.aggro(target)


## Larga o alvo e fica parado.
func calm() -> void:
	brain.calm()


## Devolve se o inimigo está em combate.
func is_aggressive() -> bool:
	return brain.is_aggressive()


## Define onde os projéteis do inimigo são adicionados.
func set_projectile_parent(parent: Node) -> void:
	brain.context.projectile_parent = parent


## Fora de combate, quem bate vira o alvo.
func _on_hurt_box_hit_received(hit: HitInfo, _outcome: int) -> void:
	if not is_aggressive() and hit.attacker != null:
		aggro(hit.attacker)


## Avisa a morte com `died` e sai da cena.
func _on_health_died() -> void:
	died.emit(self)
	queue_free()
