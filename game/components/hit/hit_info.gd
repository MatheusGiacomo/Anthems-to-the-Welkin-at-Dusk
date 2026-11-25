class_name HitInfo
extends RefCounted
## Um golpe a caminho de uma HurtBox: o ataque, a direção em que ele viaja e quem o deu.

var attack: AttackData
## Direção, no chão e normalizada, em que o golpe viaja até o defensor.
var direction: Vector3
## Quem deu o golpe (pode ser nulo); o inimigo atingido fica agressivo contra ele.
var attacker: Node3D


## Cria o golpe de `attack` viajando em `direction` (normalizada no chão), dado por `attacker`.
func _init(hit_attack: AttackData, hit_direction: Vector3, hit_attacker: Node3D = null) -> void:
	attack = hit_attack
	direction = CombatGeometry.flatten(hit_direction).normalized()
	attacker = hit_attacker
