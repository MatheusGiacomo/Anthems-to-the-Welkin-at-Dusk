class_name KnockbackComponent
extends Node
## Empurra a entidade para trás quando um golpe chega à `HurtBox` dela. A distância vem do ataque
## (`AttackData.knockback_distance`); a fração, do resultado (`KnockbackRules.outcome_scale`).
## O movimento do empurrão fica com o `LocomotionComponent`.

@export var hurt_box: HurtBox
@export var locomotion: LocomotionComponent
## Segundos que o empurrão dura (a entidade não controla o movimento nesse tempo).
@export var duration: float = 0.15
## Multiplicador da distância para esta entidade (0 = não é empurrada; acima de 1 = mais leve).
@export var resistance: float = 1.0
## Fração do empurrão quando o escudo defende o golpe.
@export var blocked_scale: float = 0.5


## Passa a ouvir os golpes da HurtBox. Avisa se faltar uma dependência.
func _ready() -> void:
	if hurt_box == null or locomotion == null:
		push_warning("%s: KnockbackComponent sem hurt_box ou locomotion." % get_path())
		return
	hurt_box.hit_received.connect(_on_hurt_box_hit_received)


## Pede à locomoção o empurrão do golpe, na direção em que ele viaja. Sem efeito se a distância
## final for zero (flechas, parry, choque).
func _on_hurt_box_hit_received(hit: HitInfo, outcome: int) -> void:
	var outcome_scale: float = KnockbackRules.outcome_scale(outcome, blocked_scale)
	var distance: float = hit.attack.knockback_distance * outcome_scale * resistance
	var speed: float = KnockbackRules.initial_speed(distance, duration)
	if speed <= 0.0:
		return
	locomotion.push(hit.direction * speed, duration)
