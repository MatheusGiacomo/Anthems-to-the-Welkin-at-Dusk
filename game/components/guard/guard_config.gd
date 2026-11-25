class_name GuardConfig
extends Resource
## Valores de um escudo ou guarda: vida, recarga, tempos para erguer de novo, janela de parry e
## arco coberto. A guarda do capanga usa o mesmo recurso, inquebrável e refletindo golpes.

## Vida do escudo. Cada golpe defendido tira o `guard_damage` do ataque.
@export var max_health: float = 100.0
## Se false, a vida nunca cai e o escudo nunca quebra.
@export var breakable: bool = true
## Segundos para a vida ir de 0 ao máximo com o escudo abaixado (a recarga é proporcional).
@export var full_regen_time: float = 1.5
## Segundos até poder erguer de novo depois que o escudo quebra.
@export var broken_lockout: float = 1.5
## Segundos até poder erguer de novo depois de abaixar por vontade própria ou interrupção.
@export var release_lockout: float = 0.5
## Segundos depois de erguer em que um golpe defendido conta como parry perfeito (0 = nunca).
@export var perfect_window: float = 0.5
## Abertura, em graus, do arco frontal coberto pelo escudo.
@export var arc_degrees: float = 120.0
## Se true, todo golpe defendido atordoa o atacante, sem depender de timing (guarda do capanga).
@export var reflects_attacks: bool = false
