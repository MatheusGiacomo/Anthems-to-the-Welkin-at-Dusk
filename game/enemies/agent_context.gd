class_name AgentContext
extends RefCounted
## O que os estados de um inimigo compartilham: o corpo, o movimento e o alvo. Criado pelo
## `EnemyBrain` e entregue a cada estado.

var body: CharacterBody3D
var locomotion: LocomotionComponent
## Alvo atual (nulo fora de combate).
var target: Node3D = null
## Onde os projéteis disparados são adicionados (o encontro que spawnou o inimigo).
var projectile_parent: Node = null


## Cria o contexto de `agent_body`, movido por `agent_locomotion`, sem alvo.
func _init(agent_body: CharacterBody3D, agent_locomotion: LocomotionComponent) -> void:
	body = agent_body
	locomotion = agent_locomotion


## Devolve se há um alvo válido (atribuído e ainda na memória).
func has_target() -> bool:
	return target != null and is_instance_valid(target)


## Devolve a distância no chão até o alvo, ou `INF` sem alvo.
func distance_to_target() -> float:
	if not has_target():
		return INF
	return CombatGeometry.flatten(target.global_position - body.global_position).length()


## Devolve a direção no chão até o alvo, normalizada, ou zero sem alvo.
func direction_to_target() -> Vector3:
	if not has_target():
		return Vector3.ZERO
	return CombatGeometry.direction_on_ground(body.global_position, target.global_position)
