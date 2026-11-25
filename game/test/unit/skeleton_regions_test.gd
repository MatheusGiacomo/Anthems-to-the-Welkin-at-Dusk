extends GdUnitTestSuite
## Regiões do esqueleto: o ramo de um osso inclui ele e os descendentes, nada mais.

# Rig reduzido no formato do KayKit: root → hips → (spine → chest → braço e cabeça) e perna.
const NAMES: Array[StringName] = [
	&"root", &"hips", &"spine", &"chest", &"upperarm.l", &"head", &"upperleg.l", &"lowerleg.l"
]
const PARENTS: PackedInt32Array = [-1, 0, 1, 2, 3, 3, 1, 6]


func test_branch_holds_root_bone_and_descendants() -> void:
	var bones: Array[StringName] = SkeletonRegions.branch(&"spine", NAMES, PARENTS)
	assert_array(bones).contains_exactly([&"spine", &"chest", &"upperarm.l", &"head"])


func test_branch_leaves_out_parents_and_siblings() -> void:
	var bones: Array[StringName] = SkeletonRegions.branch(&"spine", NAMES, PARENTS)
	assert_array(bones).not_contains([&"root", &"hips", &"upperleg.l", &"lowerleg.l"])


func test_branch_of_leaf_is_only_the_leaf() -> void:
	var bones: Array[StringName] = SkeletonRegions.branch(&"lowerleg.l", NAMES, PARENTS)
	assert_array(bones).contains_exactly([&"lowerleg.l"])


func test_missing_root_bone_gives_empty_branch() -> void:
	var bones: Array[StringName] = SkeletonRegions.branch(&"tail", NAMES, PARENTS)
	assert_array(bones).is_empty()
