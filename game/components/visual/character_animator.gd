class_name CharacterAnimator
extends Node
## Anima um modelo pelo estado do combate: lê os componentes a cada quadro, escolhe os clipes com
## `AnimationRules` e os toca numa `AnimationTree` de duas camadas, montada em código. A de baixo
## toca o corpo inteiro (locomoção, golpe, atordoado...); a de cima toca a guarda só do tronco
## para cima (`AnimationSet.upper_body_root`), para as pernas andarem com a guarda erguida.
## Não muda regra de jogo: só lê. Os componentes de combate são opcionais; sem eles, a situação
## correspondente nunca ocorre.

# Nós da árvore: base (transição entre clipes) → base_speed → layer.in; overlay → layer.blend.
const BASE_NODE: StringName = &"base"
const BASE_SPEED_NODE: StringName = &"base_speed"
const OVERLAY_NODE: StringName = &"overlay"
const LAYER_NODE: StringName = &"layer"
const OVERLAY_CLIPS: Array[AnimationRules.Clip] = [
	AnimationRules.Clip.GUARD, AnimationRules.Clip.GUARD_HIT
]

## `AnimationPlayer` do modelo importado; vira só a biblioteca de clipes da árvore.
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

var _tree: AnimationTree
var _current_clip: int = -1
var _current_overlay: int = -1
var _overlay_weight: float = 0.0
var _restart_requested: bool = false
var _guard_hit_left: float = 0.0


## Confere os clipes, marca os de locomoção e guarda como repetidos, monta a árvore de camadas e
## escuta os eventos que recomeçam um clipe.
func _ready() -> void:
	if animation_player == null or animations == null or body == null:
		push_warning("%s: CharacterAnimator sem animation_player, animations ou body." % get_path())
		set_process(false)
		return
	_check_clips()
	for clip_name: StringName in animations.looping_clips():
		if animation_player.has_animation(clip_name):
			animation_player.get_animation(clip_name).loop_mode = Animation.LOOP_LINEAR
	_tree = _build_tree()
	if attack != null:
		attack.attack_started.connect(_on_attack_attack_started)
	if hurt_box != null:
		hurt_box.hit_received.connect(_on_hurt_box_hit_received)
	if guard != null:
		guard.blocked.connect(_on_guard_blocked)


## Escolhe os clipes das duas camadas, troca com transição quando mudam (ou recomeça quando
## pedido), ajusta a velocidade da camada de baixo e o peso da de cima.
func _process(delta: float) -> void:
	_guard_hit_left = maxf(_guard_hit_left - delta, 0.0)
	var state: AnimationState = _read_state()
	var clip: AnimationRules.Clip = AnimationRules.pick(state, animations)
	var clip_name: StringName = animations.clip_name(clip)
	if animation_player.has_animation(clip_name):
		if clip != _current_clip or _restart_requested:
			_tree.set(_request_path(BASE_NODE), _input_name(clip))
			_current_clip = clip
		var length: float = animation_player.get_animation(clip_name).length
		var speed: float = AnimationRules.playback_speed(clip, state, animations, length)
		_tree.set(_parameter_path(BASE_SPEED_NODE, &"scale"), speed)
	var overlay_on: bool = AnimationRules.has_overlay(state)
	if overlay_on:
		var overlay: AnimationRules.Clip = AnimationRules.overlay_clip(state)
		if overlay != _current_overlay or _restart_requested:
			_tree.set(_request_path(OVERLAY_NODE), _input_name(overlay))
			_current_overlay = overlay
	_restart_requested = false
	var weight_step: float = delta / maxf(animations.blend_time, 0.001)
	_overlay_weight = move_toward(_overlay_weight, 1.0 if overlay_on else 0.0, weight_step)
	_tree.set(_parameter_path(LAYER_NODE, &"blend_amount"), _overlay_weight)


## Devolve o clipe que a camada de baixo (corpo inteiro) está tocando, ou -1 antes do primeiro.
func get_base_clip() -> int:
	return _current_clip


## Devolve o clipe da camada de cima (guarda ou defesa), ou -1 se ela nunca tocou.
func get_overlay_clip() -> int:
	return _current_overlay


## Devolve quanto a camada de cima cobre o tronco agora: 0 (nada) a 1 (só a guarda).
func get_overlay_weight() -> float:
	return _overlay_weight


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


## Cria a `AnimationTree` como filha deste nó, ligada aos clipes do `animation_player`, e a
## devolve. Camada de baixo: transição entre todos os clipes e escala de velocidade. Camada de
## cima: transição entre guarda e defesa, misturada só nos ossos do tronco para cima.
func _build_tree() -> AnimationTree:
	var blend_tree: AnimationNodeBlendTree = AnimationNodeBlendTree.new()
	var all_clips: Array[AnimationRules.Clip] = []
	for clip: int in AnimationRules.Clip.values():
		all_clips.append(clip as AnimationRules.Clip)
	_add_transition(blend_tree, BASE_NODE, all_clips)
	_add_transition(blend_tree, OVERLAY_NODE, OVERLAY_CLIPS)
	blend_tree.add_node(BASE_SPEED_NODE, AnimationNodeTimeScale.new())
	blend_tree.connect_node(BASE_SPEED_NODE, 0, BASE_NODE)
	var layer: AnimationNodeBlend2 = AnimationNodeBlend2.new()
	layer.filter_enabled = true
	for path: NodePath in _upper_body_paths():
		layer.set_filter_path(path, true)
	blend_tree.add_node(LAYER_NODE, layer)
	blend_tree.connect_node(LAYER_NODE, 0, BASE_SPEED_NODE)
	blend_tree.connect_node(LAYER_NODE, 1, OVERLAY_NODE)
	blend_tree.connect_node(&"output", 0, LAYER_NODE)
	var tree: AnimationTree = AnimationTree.new()
	tree.name = &"AnimationTree"
	tree.tree_root = blend_tree
	add_child(tree)
	tree.anim_player = tree.get_path_to(animation_player)
	tree.root_node = tree.get_path_to(animation_player.get_node(animation_player.root_node))
	return tree


## Acrescenta a `blend_tree` uma transição `node_name` com uma entrada por clipe de `clips`, cada
## uma tocando o clipe do `AnimationSet`. Trocar de clipe mistura em `blend_time`; pedir o mesmo
## clipe o recomeça.
func _add_transition(
	blend_tree: AnimationNodeBlendTree, node_name: StringName, clips: Array[AnimationRules.Clip]
) -> void:
	var transition: AnimationNodeTransition = AnimationNodeTransition.new()
	transition.xfade_time = animations.blend_time
	transition.allow_transition_to_self = true
	blend_tree.add_node(node_name, transition)
	for index: int in clips.size():
		var clip: AnimationRules.Clip = clips[index]
		var source: AnimationNodeAnimation = AnimationNodeAnimation.new()
		source.animation = animations.clip_name(clip)
		var source_name: StringName = StringName("%s_%s" % [node_name, _input_name(clip)])
		blend_tree.add_node(source_name, source)
		transition.add_input(_input_name(clip))
		blend_tree.connect_node(node_name, index, source_name)


## Devolve os caminhos de trilha (`esqueleto:osso`) do tronco para cima: o osso
## `upper_body_root` e os descendentes, em cada `Skeleton3D` do modelo.
func _upper_body_paths() -> Array[NodePath]:
	var paths: Array[NodePath] = []
	var model_root: Node = animation_player.get_node(animation_player.root_node)
	for found: Node in model_root.find_children("*", "Skeleton3D"):
		var skeleton: Skeleton3D = found as Skeleton3D
		var bone_names: Array[StringName] = []
		var bone_parents: PackedInt32Array = []
		for bone: int in skeleton.get_bone_count():
			bone_names.append(StringName(skeleton.get_bone_name(bone)))
			bone_parents.append(skeleton.get_bone_parent(bone))
		var skeleton_path: String = str(model_root.get_path_to(skeleton))
		var upper_bones: Array[StringName] = SkeletonRegions.branch(
			animations.upper_body_root, bone_names, bone_parents
		)
		for bone_name: StringName in upper_bones:
			paths.append(NodePath("%s:%s" % [skeleton_path, bone_name]))
	if paths.is_empty():
		push_warning('%s: nenhum osso "%s" no modelo.' % [get_path(), animations.upper_body_root])
	return paths


## Devolve o nome da entrada de `clip` nas transições da árvore.
func _input_name(clip: AnimationRules.Clip) -> String:
	return AnimationRules.Clip.keys()[clip]


## Devolve o caminho do parâmetro que pede a troca de clipe na transição `node_name`.
func _request_path(node_name: StringName) -> StringName:
	return _parameter_path(node_name, &"transition_request")


## Devolve o caminho do parâmetro `parameter` do nó `node_name` da árvore.
func _parameter_path(node_name: StringName, parameter: StringName) -> StringName:
	return StringName("parameters/%s/%s" % [node_name, parameter])


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
