class_name CharacterAnimator
extends Node
## Anima um modelo pelo estado do combate: lê os componentes a cada quadro, escolhe o clipe com
## `AnimationRules` e o toca com transição. Não muda regra de jogo: só lê.
## Os componentes de combate são opcionais; sem eles, a situação correspondente nunca ocorre.

## `AnimationPlayer` do modelo importado.
@export var animation_player: AnimationPlayer
@export var animations: AnimationSet
## Corpo de onde vêm a velocidade e a frente.
@export var body: CharacterBody3D
@export var health: HealthComponent
@export var vulnerability: VulnerabilityComponent
@export var guard: GuardComponent
@export var attack: MeleeAttackComponent
## Para recomeçar o clipe de atordoado a cada golpe recebido (o combo).
@export var hurt_box: HurtBox
## Para os clipes de puxar e soltar o tiro.
@export var ranged_state: RangedAttackState

var _current_clip: int = -1
var _restart_requested: bool = false
var _guard_hit_left: float = 0.0


## Confere os clipes, marca os de locomoção e guarda como repetidos e escuta os eventos que
## recomeçam um clipe.
func _ready() -> void:
	if animation_player == null or animations == null or body == null:
		push_warning("%s: CharacterAnimator sem animation_player, animations ou body." % get_path())
		set_process(false)
		return
	_check_clips()
	for clip_name: StringName in animations.looping_clips():
		if animation_player.has_animation(clip_name):
			animation_player.get_animation(clip_name).loop_mode = Animation.LOOP_LINEAR
	if attack != null:
		attack.attack_started.connect(_on_attack_attack_started)
	if hurt_box != null:
		hurt_box.hit_received.connect(_on_hurt_box_hit_received)
	if guard != null:
		guard.blocked.connect(_on_guard_blocked)


## Escolhe o clipe do estado atual, troca com transição quando ele muda (ou recomeça quando
## pedido) e ajusta a velocidade de reprodução.
func _process(delta: float) -> void:
	_guard_hit_left = maxf(_guard_hit_left - delta, 0.0)
	var state: AnimationState = _read_state()
	var clip: AnimationRules.Clip = AnimationRules.pick(state, animations)
	var clip_name: StringName = animations.clip_name(clip)
	if not animation_player.has_animation(clip_name):
		return
	if clip != _current_clip:
		animation_player.play(clip_name, animations.blend_time)
		_current_clip = clip
	elif _restart_requested:
		animation_player.play(clip_name, animations.blend_time)
		animation_player.seek(0.0, true)
	_restart_requested = false
	var length: float = animation_player.get_animation(clip_name).length
	animation_player.speed_scale = AnimationRules.playback_speed(clip, state, animations, length)


## Devolve a fotografia do estado da entidade lida dos componentes.
func _read_state() -> AnimationState:
	var state: AnimationState = AnimationState.new()
	state.velocity = body.velocity
	state.facing = CombatGeometry.forward_of(body)
	state.dead = health != null and health.is_dead()
	state.staggered = vulnerability != null and vulnerability.is_vulnerable()
	if attack != null and attack.is_attacking():
		state.attacking = true
		state.attack_duration = attack.data.get_duration()
	if guard != null and guard.is_raised():
		state.guarding = true
		state.guard_hit = _guard_hit_left > 0.0
	if ranged_state != null:
		state.drawing = ranged_state.is_drawing()
		state.draw_duration = ranged_state.behavior.draw_time
		var shoot_length: float = _clip_length(animations.shoot)
		state.recently_shot = ranged_state.get_seconds_since_shot() < shoot_length
	return state


## Devolve o comprimento do clipe `clip_name`, ou 0 se o modelo não o tiver.
func _clip_length(clip_name: StringName) -> float:
	if not animation_player.has_animation(clip_name):
		return 0.0
	return animation_player.get_animation(clip_name).length


## Avisa os clipes do `AnimationSet` que o modelo não tem.
func _check_clips() -> void:
	for clip: int in AnimationRules.Clip.values():
		var clip_name: StringName = animations.clip_name(clip as AnimationRules.Clip)
		if not animation_player.has_animation(clip_name):
			push_warning('%s: o modelo não tem o clipe "%s".' % [get_path(), clip_name])


## Um ataque novo recomeça o clipe de golpe, mesmo emendado no anterior.
func _on_attack_attack_started() -> void:
	_restart_requested = true


## Um golpe que acerta durante a vulnerabilidade recomeça o clipe de atordoado.
func _on_hurt_box_hit_received(_hit: HitInfo, outcome: int) -> void:
	if outcome == HitResolver.Outcome.HIT:
		_restart_requested = true


## Um golpe defendido mostra o clipe de defesa enquanto a guarda continuar erguida.
func _on_guard_blocked(_perfect: bool, _broke: bool) -> void:
	_guard_hit_left = _clip_length(animations.guard_hit)
	_restart_requested = true
