class_name ModelLoadout
extends Node
## Escolhe o que um modelo KayKit leva nas mãos: os acessórios presos aos encaixes das mãos ficam
## escondidos, exceto os listados, e uma arma extra pode ser presa a um encaixe. Opcionalmente,
## troca para um segundo conjunto de acessórios em certos estados da IA.

## Raiz do modelo importado.
@export var model: Node3D
## Nomes dos nós de encaixe (BoneAttachment3D) cujos filhos são acessórios trocáveis.
@export var slot_names: Array[StringName] = [&"handslot_l", &"handslot_r"]
## Acessórios do modelo que ficam visíveis.
@export var accessories: Array[StringName] = []

@export_group("Arma extra")
## Cena de uma arma que o modelo não traz (fica sempre visível).
@export var extra_weapon: PackedScene
## Encaixe onde a arma extra é presa.
@export var extra_weapon_slot: StringName = &"handslot_r"
## Posição da arma extra em relação ao encaixe.
@export var extra_weapon_transform: Transform3D = Transform3D.IDENTITY

@export_group("Troca por estado")
## Máquina de estados cujos estados escolhem o conjunto de acessórios (opcional).
@export var state_machine: StateMachine
## Nomes dos estados que usam `alternate_accessories` em vez de `accessories`.
@export var alternate_states: Array[StringName] = []
@export var alternate_accessories: Array[StringName] = []

var _slots: Array[Node3D] = []


## Encontra os encaixes, prende a arma extra, mostra o conjunto inicial e escuta a troca de estado.
func _ready() -> void:
	if model == null:
		push_warning("%s: ModelLoadout sem model." % get_path())
		return
	for slot_name: StringName in slot_names:
		var slot: Node3D = model.find_child(slot_name, true, false) as Node3D
		if slot != null:
			_slots.append(slot)
	_show_only(accessories)
	_mount_extra_weapon()
	if state_machine != null:
		state_machine.state_changed.connect(_on_state_machine_state_changed)


## Deixa visíveis, nos encaixes, só os acessórios de `names`; a arma extra não é tocada e segue
## sempre visível.
func _show_only(names: Array[StringName]) -> void:
	for slot: Node3D in _slots:
		for child: Node in slot.get_children():
			var item: Node3D = child as Node3D
			if item != null and item.has_meta(&"extra_weapon"):
				continue
			if item != null:
				item.visible = names.has(StringName(item.name))


## Instancia a arma extra no encaixe dela, na posição configurada.
func _mount_extra_weapon() -> void:
	if extra_weapon == null:
		return
	var slot: Node3D = model.find_child(extra_weapon_slot, true, false) as Node3D
	if slot == null:
		push_warning('%s: encaixe "%s" não encontrado.' % [get_path(), extra_weapon_slot])
		return
	var weapon: Node3D = extra_weapon.instantiate() as Node3D
	weapon.set_meta(&"extra_weapon", true)
	slot.add_child(weapon)
	weapon.transform = extra_weapon_transform


## Usa o conjunto alternativo nos estados listados e o principal nos demais.
func _on_state_machine_state_changed(state: State) -> void:
	if state == null:
		return
	if alternate_states.has(StringName(state.name)):
		_show_only(alternate_accessories)
	else:
		_show_only(accessories)
