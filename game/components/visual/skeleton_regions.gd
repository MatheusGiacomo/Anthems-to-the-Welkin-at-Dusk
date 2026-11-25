class_name SkeletonRegions
extends RefCounted
## Regras puras das regiões do esqueleto: quais ossos pertencem a um ramo da hierarquia.


## Devolve `root_bone` e todos os ossos abaixo dele, na ordem do esqueleto. `bone_names[i]` é o
## nome do osso i e `bone_parents[i]`, o índice do pai dele (-1 na raiz). Vazio se `root_bone`
## não existir.
static func branch(
	root_bone: StringName, bone_names: Array[StringName], bone_parents: PackedInt32Array
) -> Array[StringName]:
	var branch_bones: Array[StringName] = []
	var root_index: int = bone_names.find(root_bone)
	if root_index < 0:
		return branch_bones
	for index: int in bone_names.size():
		if _descends_from(index, root_index, bone_parents):
			branch_bones.append(bone_names[index])
	return branch_bones


## Devolve se o osso `index` é `ancestor` ou está abaixo dele, subindo pelos pais.
static func _descends_from(index: int, ancestor: int, bone_parents: PackedInt32Array) -> bool:
	var current: int = index
	while current >= 0:
		if current == ancestor:
			return true
		current = bone_parents[current]
	return false
