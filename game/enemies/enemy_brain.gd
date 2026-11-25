class_name EnemyBrain
extends StateMachine
## Cérebro base de um inimigo: guarda o alvo, cuida da vulnerabilidade (entra e sai do estado
## atordoado) e entrega as decisões de combate às subclasses, uma por tipo de inimigo.

@export var body: CharacterBody3D
@export var locomotion: LocomotionComponent
@export var vulnerability: VulnerabilityComponent
@export var idle_state: EnemyState
@export var staggered_state: EnemyState

## Contexto compartilhado com os estados (corpo, movimento, alvo).
var context: AgentContext

var _aggressive: bool = false


## Cria o contexto, entrega-o aos estados, escuta a vulnerabilidade e começa parado.
func _ready() -> void:
	super()
	context = AgentContext.new(body, locomotion)
	for child: Node in get_children():
		var state: EnemyState = child as EnemyState
		if state != null:
			state.setup(context)
	vulnerability.vulnerable_started.connect(_on_vulnerability_vulnerable_started)
	vulnerability.vulnerable_ended.connect(_on_vulnerability_vulnerable_ended)
	transition_to(idle_state)


## Roda o estado atual e, em combate e fora da vulnerabilidade, deixa a subclasse decidir. Se o
## alvo deixou de existir, volta a ficar parado.
func _physics_process(delta: float) -> void:
	if _aggressive and not context.has_target():
		calm()
	super(delta)
	if _aggressive and current != staggered_state:
		_update_combat()


## Passa a lutar contra `target`. Se estiver vulnerável, começa quando o estado acabar.
func aggro(target: Node3D) -> void:
	context.target = target
	_aggressive = true
	if not vulnerability.is_vulnerable():
		_start_combat()


## Larga o alvo e fica parado.
func calm() -> void:
	context.target = null
	_aggressive = false
	transition_to(idle_state)


## Devolve se o inimigo está em combate (com alvo).
func is_aggressive() -> bool:
	return _aggressive


## Ponto de extensão: escolhe o primeiro estado de combate depois de `aggro`.
func _start_combat() -> void:
	pass


## Ponto de extensão: chamado a cada quadro de física em combate, fora da vulnerabilidade, para
## trocar de estado pela distância.
func _update_combat() -> void:
	pass


## Ponto de extensão: escolhe o estado ao sair da vulnerabilidade, em combate.
func _resume_after_stagger() -> void:
	_start_combat()


## Ao ficar vulnerável, interrompe o estado atual (o `exit` dele cancela ataque e guarda).
func _on_vulnerability_vulnerable_started() -> void:
	transition_to(staggered_state)


## Ao sair da vulnerabilidade, volta ao combate ou, sem alvo, fica parado.
func _on_vulnerability_vulnerable_ended() -> void:
	if _aggressive:
		_resume_after_stagger()
	else:
		transition_to(idle_state)
