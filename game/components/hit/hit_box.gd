class_name HitBox
extends Area3D
## Área de um golpe. Enquanto ligada, entrega o golpe uma vez a cada HurtBox que a sobrepõe e
## aplica no próprio dono o efeito do resultado: atordoamento por parry, guarda que reflete ou
## choque de espadas. A máscara de colisão define quem ela pode atingir.

signal hit_resolved(hurt_box: HurtBox, outcome: int)

## Medidor do dono, que recebe o atordoamento quando o golpe é aparado, refletido ou tromba.
@export var vulnerability: VulnerabilityComponent
## Dono do golpe: origem da direção do golpe e quem o atingido passa a ter como alvo.
@export var source: Node3D

var _attack: AttackData = null
var _already_hit: Array[HurtBox] = []


## Avisa se faltar uma dependência obrigatória.
func _ready() -> void:
	if vulnerability == null or source == null:
		push_warning("%s: HitBox sem vulnerability ou source." % get_path())


## Entrega o golpe às HurtBoxes sobrepostas que ainda não foram atingidas neste golpe. Para se o
## golpe for desligado no meio (o dono foi atordoado).
func _physics_process(_delta: float) -> void:
	if _attack == null:
		return
	for area: Area3D in get_overlapping_areas():
		if _attack == null:
			return
		var hurt_box: HurtBox = area as HurtBox
		if hurt_box == null or _already_hit.has(hurt_box):
			continue
		_already_hit.append(hurt_box)
		_strike(hurt_box)


## Liga a área com o golpe `attack`; cada HurtBox pode ser atingida uma vez até desligar.
func enable(attack: AttackData) -> void:
	_attack = attack
	_already_hit.clear()


## Desliga a área: nada mais é atingido até o próximo `enable`.
func disable() -> void:
	_attack = null
	_already_hit.clear()


## Devolve se a área está ligada com um golpe.
func is_enabled() -> bool:
	return _attack != null


## Entrega o golpe a `hurt_box`, aplica no dono o efeito do resultado e emite `hit_resolved`.
func _strike(hurt_box: HurtBox) -> void:
	var direction: Vector3 = CombatGeometry.direction_on_ground(
		source.global_position, hurt_box.global_position
	)
	if direction == Vector3.ZERO:
		direction = CombatGeometry.forward_of(source)
	var outcome: HitResolver.Outcome = hurt_box.receive_hit(HitInfo.new(_attack, direction, source))
	_apply_to_owner(outcome)
	hit_resolved.emit(hurt_box, outcome)


## Atordoa o dono quando o golpe foi aparado, refletido ou trombou, pela duração da config dele.
func _apply_to_owner(outcome: HitResolver.Outcome) -> void:
	if vulnerability == null:
		return
	match outcome:
		HitResolver.Outcome.PARRIED:
			vulnerability.stun(vulnerability.config.parried_duration)
		HitResolver.Outcome.REFLECTED:
			vulnerability.stun(vulnerability.config.reflected_duration)
		HitResolver.Outcome.CLASHED:
			vulnerability.stun(vulnerability.config.clash_duration)
