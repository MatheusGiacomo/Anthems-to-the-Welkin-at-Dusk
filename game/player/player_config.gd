class_name PlayerConfig
extends Resource
## Valores de movimento do player. Os de combate ficam nos recursos de cada componente
## (`AttackData`, `GuardConfig`, `VulnerabilityConfig`).

## Velocidade base, em metros por segundo, andando para onde olha.
@export var move_speed: float = 5.0
## Multiplicador andando na direção em que olha.
@export var forward_multiplier: float = 1.0
## Multiplicador andando de costas; de lado, vale a média com `forward_multiplier`.
@export var backward_multiplier: float = 0.6
## Multiplicador extra com o escudo erguido.
@export var blocking_multiplier: float = 0.5
## Multiplicador extra durante um ataque.
@export var attacking_multiplier: float = 0.3
## Se true, a direção do olhar fica travada do início ao fim de um ataque.
@export var lock_facing_while_attacking: bool = true
## Fração do intervalo do próximo ataque depois de um parry perfeito (0,5 = metade).
@export var perfect_parry_cooldown_scale: float = 0.5
