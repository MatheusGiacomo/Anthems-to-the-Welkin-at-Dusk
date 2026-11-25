class_name DefenseState
extends RefCounted
## Fotografia do defensor no instante de um golpe, lida pela HurtBox e entregue ao `HitResolver`.

## Escudo erguido.
var guard_raised: bool = false
## O atacante está dentro do arco coberto pelo escudo.
var guard_covers: bool = false
## O escudo está na janela de parry perfeito.
var guard_perfect: bool = false
## O escudo reflete todo golpe defendido (guarda do capanga).
var guard_reflects: bool = false
## O golpe quebraria o escudo.
var guard_would_break: bool = false
## O defensor está na fase de golpe do próprio ataque.
var attacking_active: bool = false
## O defensor está de frente para o atacante (condição do choque de espadas).
var facing_attacker: bool = false
