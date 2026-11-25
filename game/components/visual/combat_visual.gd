class_name CombatVisual
extends Node
## Avisos visuais de leitura do combate sobre o modelo: uma sobreposição de cor em todas as
## malhas no preparo do ataque, na vulnerabilidade e na morte, o escudo provisório quando erguido
## e o arco do golpe na fase ativa. Só lê os componentes.

## Raiz do modelo; todas as malhas abaixo dela recebem a sobreposição de cor.
@export var model_root: Node3D
## Opcional: nó mostrado enquanto o escudo está erguido (para modelos sem escudo próprio).
@export var guard_mesh: Node3D
## Opcional: nó mostrado na fase de golpe do ataque.
@export var slash_mesh: Node3D
@export var vulnerability: VulnerabilityComponent
## Opcional.
@export var guard: GuardComponent
## Opcional.
@export var attack: MeleeAttackComponent
## Opcional: sem ele, a morte não muda a cor.
@export var health: HealthComponent
## Sobreposição no preparo do ataque (o aviso do golpe); a transparência dá a intensidade.
@export var windup_color: Color = Color(1.0, 0.5, 0.1, 0.45)
## Sobreposição enquanto vulnerável (atordoado).
@export var vulnerable_color: Color = Color(1.0, 0.95, 0.3, 0.45)
## Sobreposição depois da morte.
@export var dead_color: Color = Color(0.1, 0.1, 0.1, 0.6)

var _overlay: StandardMaterial3D
var _meshes: Array[MeshInstance3D] = []
var _tinted: bool = false


## Junta as malhas do modelo e cria o material de sobreposição, sem luz e translúcido.
func _ready() -> void:
	_overlay = StandardMaterial3D.new()
	_overlay.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_overlay.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if model_root == null:
		return
	for child: Node in model_root.find_children("*", "MeshInstance3D", true, false):
		_meshes.append(child as MeshInstance3D)


## Atualiza a visibilidade do escudo provisório e do golpe e a sobreposição de cor.
func _process(_delta: float) -> void:
	if guard_mesh != null and guard != null:
		guard_mesh.visible = guard.is_raised()
	if slash_mesh != null and attack != null:
		slash_mesh.visible = attack.is_in_active_phase()
	var color: Color = _current_color()
	var tinted: bool = color.a > 0.0
	if tinted:
		_overlay.albedo_color = color
	if tinted != _tinted:
		_tinted = tinted
		for mesh: MeshInstance3D in _meshes:
			mesh.material_overlay = _overlay if tinted else null


## Devolve a sobreposição do estado atual: morto, vulnerável, preparando o golpe ou nenhuma
## (transparente).
func _current_color() -> Color:
	if health != null and health.is_dead():
		return dead_color
	if vulnerability != null and vulnerability.is_vulnerable():
		return vulnerable_color
	if attack != null and attack.get_phase() == AttackCycle.Phase.WINDUP:
		return windup_color
	return Color.TRANSPARENT
