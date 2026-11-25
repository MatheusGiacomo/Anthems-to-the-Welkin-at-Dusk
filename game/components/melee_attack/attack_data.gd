class_name AttackData
extends Resource
## Dados de um ataque (golpe de espada, adaga, flecha): efeitos no alvo, como ele pode ser
## defendido e, para ataques corpo a corpo, as fases e o limite de ritmo.

## Vida que o golpe tira de quem é atingido.
@export var damage: float = 10.0
## Pontos que o golpe soma ao medidor de vulnerabilidade de quem é atingido.
@export var vulnerability_points: float = 100.0
## Vida que o golpe tira de um escudo que o defende.
@export var guard_damage: float = 100.0
## Se um escudo erguido de frente pode defender o golpe.
@export var blockable: bool = true
## Se o golpe pode ser aparado com timing perfeito (flechas não podem).
@export var parryable: bool = true
## Se o golpe pode trombar com outro golpe ativo (choque de espadas).
@export var can_clash: bool = true
## Metros que o golpe empurra quem é atingido (0 = não empurra). Com o escudo defendendo, empurra
## uma fração (`KnockbackComponent.blocked_scale`).
@export var knockback_distance: float = 0.0

@export_group("Tempo (corpo a corpo)")
## Segundos de preparo antes do golpe valer.
@export var windup: float = 0.15
## Segundos em que o golpe acerta quem estiver na área.
@export var active: float = 0.15
## Segundos de recuperação depois do golpe.
@export var recovery: float = 0.3
## Limite de ataques por segundo, contado do início de um ataque ao do próximo
## (0 = só a duração do próprio ataque limita).
@export var attacks_per_second: float = 0.0


## Devolve a duração total do ataque, em segundos (preparo + golpe + recuperação).
func get_duration() -> float:
	return windup + active + recovery


## Devolve os segundos entre o início de um ataque e o início do próximo: o maior valor entre a
## duração do ataque e o intervalo dado por `attacks_per_second`.
func get_cooldown() -> float:
	if attacks_per_second <= 0.0:
		return get_duration()
	return maxf(get_duration(), 1.0 / attacks_per_second)
