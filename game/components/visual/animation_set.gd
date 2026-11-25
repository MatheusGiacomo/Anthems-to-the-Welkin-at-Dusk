class_name AnimationSet
extends Resource
## Nomes dos clipes de um modelo para cada situação do combate e as referências de velocidade da
## locomoção. Um recurso por personagem.

@export_group("Clipes")
@export var idle: StringName = &"Idle"
@export var walk: StringName = &"Walking_A"
@export var walk_backward: StringName = &"Walking_Backwards"
@export var run: StringName = &"Running_A"
@export var strafe_left: StringName = &"Running_Strafe_Left"
@export var strafe_right: StringName = &"Running_Strafe_Right"
## Golpe corpo a corpo; esticado ou comprimido para durar o mesmo que o ataque.
@export var attack: StringName = &"1H_Melee_Attack_Slice_Diagonal"
## Guarda ou escudo erguido.
@export var guard: StringName = &"Blocking"
## Golpe defendido com a guarda erguida.
@export var guard_hit: StringName = &"Block_Hit"
## Vulnerável (atordoado); recomeça a cada golpe recebido.
@export var stagger: StringName = &"Hit_A"
@export var death: StringName = &"Death_A"
## Puxando a arma de tiro; esticado ou comprimido para durar a puxada.
@export var aim: StringName = &"2H_Ranged_Aiming"
## Logo depois de soltar o tiro.
@export var shoot: StringName = &"2H_Ranged_Shoot"

@export_group("Locomoção")
## Abaixo desta velocidade (m/s), o personagem está parado.
@export var idle_speed: float = 0.2
## A partir desta velocidade (m/s), andar para a frente vira correr.
@export var run_threshold: float = 3.0
## Velocidade (m/s) em que o clipe de andar toca na velocidade normal.
@export var walk_reference_speed: float = 1.8
## Velocidade (m/s) em que os clipes de correr tocam na velocidade normal.
@export var run_reference_speed: float = 5.0
## Segundos de transição entre clipes.
@export var blend_time: float = 0.12


## Devolve o nome do clipe de `clip` (`AnimationRules.Clip`).
func clip_name(clip: AnimationRules.Clip) -> StringName:
	var names: Dictionary[AnimationRules.Clip, StringName] = {
		AnimationRules.Clip.IDLE: idle,
		AnimationRules.Clip.WALK: walk,
		AnimationRules.Clip.WALK_BACKWARD: walk_backward,
		AnimationRules.Clip.RUN: run,
		AnimationRules.Clip.STRAFE_LEFT: strafe_left,
		AnimationRules.Clip.STRAFE_RIGHT: strafe_right,
		AnimationRules.Clip.ATTACK: attack,
		AnimationRules.Clip.GUARD: guard,
		AnimationRules.Clip.GUARD_HIT: guard_hit,
		AnimationRules.Clip.STAGGER: stagger,
		AnimationRules.Clip.DEATH: death,
		AnimationRules.Clip.AIM: aim,
		AnimationRules.Clip.SHOOT: shoot,
	}
	return names.get(clip, idle)


## Devolve os clipes que repetem enquanto a situação dura (locomoção e guarda).
func looping_clips() -> Array[StringName]:
	return [idle, walk, walk_backward, run, strafe_left, strafe_right, guard]
