class_name PlayerConfig
extends Resource
## Valores de movimento do player. Os de combate ficam nos recursos de cada componente
## (`AttackData`, `GuardConfig`, `VulnerabilityConfig`).

## Velocidade, em metros por segundo, em qualquer direção.
@export var move_speed: float = 5.0
## Multiplicador extra com o escudo erguido.
@export var blocking_multiplier: float = 0.5
## Multiplicador extra durante um ataque.
@export var attacking_multiplier: float = 0.3
## Se true, a direção do olhar fica travada do início ao fim de um ataque.
@export var lock_facing_while_attacking: bool = true
## Se true, a direção do olhar fica travada enquanto o escudo está erguido (anda de lado ou de
## costas defendendo).
@export var lock_facing_while_blocking: bool = true
## Fração do intervalo do próximo ataque depois de abaixar o escudo (soltar, quebrar ou ser
## interrompido), exceto após um parry perfeito (0,5 = metade, 1 = intervalo inteiro).
@export var guard_lowered_cooldown_scale: float = 0.5
## Fração do intervalo do próximo ataque depois de um parry perfeito (0,5 = metade).
@export var perfect_parry_cooldown_scale: float = 0.5
