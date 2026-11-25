class_name AnimationState
extends RefCounted
## Fotografia, a cada quadro, do que o animador precisa saber da entidade. Montada pelo
## `CharacterAnimator` e lida por `AnimationRules`.

var dead: bool = false
var staggered: bool = false
var attacking: bool = false
## Duração total do ataque em curso, em segundos.
var attack_duration: float = 0.0
## Puxando a arma de tiro.
var drawing: bool = false
## Duração da puxada, em segundos.
var draw_duration: float = 0.0
## O tiro acabou de sair (dentro da duração do clipe de tiro).
var recently_shot: bool = false
var guarding: bool = false
## A guarda acabou de defender um golpe (dentro da duração do clipe de defesa).
var guard_hit: bool = false
## Velocidade do corpo, em m/s.
var velocity: Vector3 = Vector3.ZERO
## Frente do corpo no chão.
var facing: Vector3 = Vector3.FORWARD
