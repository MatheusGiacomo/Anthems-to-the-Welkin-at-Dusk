class_name CombatVisual
extends Node
## Mostra o estado de combate num visual provisório: escudo visível quando erguido, arco do golpe
## na fase ativa e cor do corpo no preparo do ataque e na vulnerabilidade. Só lê os componentes.

## Malha do corpo, cuja cor muda conforme o estado (o material dela é duplicado no início).
@export var body_mesh: MeshInstance3D
## Opcional: nó mostrado enquanto o escudo está erguido.
@export var guard_mesh: Node3D
## Opcional: nó mostrado na fase de golpe do ataque.
@export var slash_mesh: Node3D
@export var vulnerability: VulnerabilityComponent
## Opcional.
@export var guard: GuardComponent
## Opcional.
@export var attack: MeleeAttackComponent
## Cor do corpo no preparo do ataque (o aviso do golpe).
@export var windup_color: Color = Color(1.0, 0.6, 0.15)
## Cor do corpo enquanto vulnerável (atordoado).
@export var vulnerable_color: Color = Color(1.0, 0.95, 0.3)

var _material: StandardMaterial3D
var _base_color: Color = Color.WHITE


## Duplica o material do corpo para mudar a cor só desta instância.
func _ready() -> void:
	if body_mesh == null:
		return
	var original: StandardMaterial3D = body_mesh.get_active_material(0) as StandardMaterial3D
	if original != null:
		_material = original.duplicate() as StandardMaterial3D
	else:
		_material = StandardMaterial3D.new()
	_base_color = _material.albedo_color
	body_mesh.material_override = _material


## Atualiza a visibilidade do escudo e do golpe e a cor do corpo.
func _process(_delta: float) -> void:
	if guard_mesh != null and guard != null:
		guard_mesh.visible = guard.is_raised()
	if slash_mesh != null and attack != null:
		slash_mesh.visible = attack.is_in_active_phase()
	if _material != null:
		_material.albedo_color = _current_color()


## Devolve a cor do corpo para o estado atual: vulnerável, preparando o golpe ou normal.
func _current_color() -> Color:
	if vulnerability != null and vulnerability.is_vulnerable():
		return vulnerable_color
	if attack != null and attack.get_phase() == AttackCycle.Phase.WINDUP:
		return windup_color
	return _base_color
