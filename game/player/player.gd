class_name Player
extends CharacterBody3D
## Player controlado por WASD e mouse. Lê o input e orquestra os componentes; as regras ficam
## neles e em `MovementRules`.

signal died

@export var config: PlayerConfig

## Câmera usada no movimento relativo à tela e na mira pelo mouse; atribuída pela arena.
## Sem câmera, "para frente" é -Z e o olhar não muda.
var camera: IsometricCamera

# Depois de o escudo quebrar ou ser interrompido, só ergue de novo com um novo clique: segurar o
# botão não reergue sozinho quando a espera acaba (evita um parry perfeito sem intenção).
var _needs_block_repress: bool = false

@onready var locomotion: LocomotionComponent = $Locomotion
@onready var health: HealthComponent = $Health
@onready var vulnerability: VulnerabilityComponent = $Vulnerability
@onready var guard: GuardComponent = $Guard
@onready var sword: MeleeAttackComponent = $Sword
@onready var hurt_box: HurtBox = $HurtBox


## Liga as reações aos componentes. Sem `config` atribuído, avisa e usa os valores padrão.
func _ready() -> void:
	if config == null:
		push_warning("%s: Player sem config; usando valores padrão." % get_path())
		config = PlayerConfig.new()
	vulnerability.vulnerable_started.connect(_on_vulnerability_vulnerable_started)
	guard.lowered.connect(_on_guard_lowered)
	health.died.connect(_on_health_died)


## Vulnerável ou morto, só freia. Senão, atualiza escudo, ataque, olhar e movimento, nessa ordem.
func _physics_process(delta: float) -> void:
	if not can_act():
		locomotion.move(Vector3.ZERO, delta)
		return
	_update_guard()
	_update_attack()
	_update_facing(delta)
	_update_movement(delta)


## Devolve se o player pode agir: vivo e fora da vulnerabilidade.
func can_act() -> bool:
	return not health.is_dead() and not vulnerability.is_vulnerable()


## Ergue o escudo com o botão segurado, fora de um ataque; abaixa ao soltar.
func _update_guard() -> void:
	var wants_block: bool = Input.is_action_pressed("block")
	if not wants_block:
		_needs_block_repress = false
		if guard.is_raised():
			guard.lower(GuardModel.LowerReason.RELEASED)
		return
	if not guard.is_raised() and not sword.is_attacking() and not _needs_block_repress:
		guard.raise()


## Ataca no clique, se o escudo não estiver erguido e o intervalo já tiver passado.
func _update_attack() -> void:
	if Input.is_action_just_pressed("attack") and not guard.is_raised():
		sword.try_attack()


## Gira o player para o ponto do chão sob o cursor, exceto durante um ataque com o olhar travado.
func _update_facing(delta: float) -> void:
	if camera == null:
		return
	if sword.is_attacking() and config.lock_facing_while_attacking:
		return
	var aim_point: Vector3 = camera.mouse_ground_point(global_position.y, global_position)
	locomotion.face_direction(aim_point - global_position, delta)


## Move na direção do input, relativa à câmera. A velocidade vem do alinhamento entre o
## movimento e o olhar, reduzida com o escudo erguido e durante um ataque.
func _update_movement(delta: float) -> void:
	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var camera_yaw: float = camera.get_yaw() if camera != null else 0.0
	var direction: Vector3 = MovementRules.camera_relative_direction(input, camera_yaw)
	var multiplier: float = MovementRules.alignment_multiplier(
		direction, locomotion.get_forward(), config.forward_multiplier, config.backward_multiplier
	)
	if guard.is_raised():
		multiplier *= config.blocking_multiplier
	if sword.is_attacking():
		multiplier *= config.attacking_multiplier
	locomotion.move(direction * config.move_speed * multiplier, delta)


## Ao ficar vulnerável, interrompe o ataque e abaixa o escudo.
func _on_vulnerability_vulnerable_started() -> void:
	sword.cancel()
	guard.lower(GuardModel.LowerReason.INTERRUPTED)


## Ao abaixar o escudo, por qualquer motivo, recomeça o intervalo do ataque: inteiro, ou cortado
## por `perfect_parry_cooldown_scale` se houve parry perfeito. Quebra e interrupção exigem um
## novo clique para erguer de novo.
func _on_guard_lowered(reason: int, after_perfect_parry: bool) -> void:
	var cooldown_scale: float = config.perfect_parry_cooldown_scale if after_perfect_parry else 1.0
	sword.restart_cooldown(cooldown_scale)
	if reason != GuardModel.LowerReason.RELEASED:
		_needs_block_repress = true


## Ao morrer, para de lutar, deixa de receber golpes e emite `died`.
func _on_health_died() -> void:
	sword.cancel()
	guard.lower(GuardModel.LowerReason.INTERRUPTED)
	hurt_box.set_deferred("monitorable", false)
	died.emit()
