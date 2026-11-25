extends GdUnitTestSuite
## Restrições de balanceamento do MVP V1, lidas dos .tres do jogo. Se um ajuste de números
## quebrar uma delas, este teste falha: ou o ajuste volta, ou a regra muda com o desenvolvedor.
## 1. Um único inimigo não consegue "combar" o player: a vulnerabilidade do player acaba antes do
##    próximo golpe possível do mesmo inimigo.
## 2. O combo do player encadeia: a vulnerabilidade de cada inimigo dura mais que o intervalo do
##    ataque do player somado ao preparo do golpe seguinte.

const PLAYER_VULNERABILITY: String = "res://player/player_vulnerability.tres"
const PLAYER_SWORD: String = "res://player/sword_slash.tres"
const MELEE_ATTACKS: Array[String] = [
	"res://enemies/henchman/henchman_sword.tres",
	"res://enemies/thief/thief_dagger.tres",
]
const RANGED_BEHAVIORS: Array[String] = ["res://enemies/thief/thief_ranged.tres"]
const ENEMY_VULNERABILITIES: Array[String] = [
	"res://enemies/henchman/henchman_vulnerability.tres",
	"res://enemies/thief/thief_vulnerability.tres",
]


func test_single_melee_enemy_cannot_combo_the_player() -> void:
	var player: VulnerabilityConfig = load(PLAYER_VULNERABILITY) as VulnerabilityConfig
	for path: String in MELEE_ATTACKS:
		var attack: AttackData = load(path) as AttackData
		# Do fim do golpe de um ataque ao começo do golpe do ataque seguinte.
		var gap: float = attack.get_cooldown() - attack.active
		var message: String = "%s: player vulnerável %.2f s, próximo golpe em %.2f s"
		message = message % [path, player.duration, gap]
		assert_float(player.duration).override_failure_message(message).is_less(gap)


func test_single_archer_cannot_combo_the_player() -> void:
	var player: VulnerabilityConfig = load(PLAYER_VULNERABILITY) as VulnerabilityConfig
	for path: String in RANGED_BEHAVIORS:
		var ranged: RangedBehaviorConfig = load(path) as RangedBehaviorConfig
		var gap: float = ranged.draw_time + ranged.reload_time
		var message: String = "%s: player vulnerável %.2f s, próxima flecha em %.2f s"
		message = message % [path, player.duration, gap]
		assert_float(player.duration).override_failure_message(message).is_less(gap)


func test_player_combo_chains_on_every_enemy() -> void:
	var sword: AttackData = load(PLAYER_SWORD) as AttackData
	var next_hit: float = sword.get_cooldown() + sword.windup
	for path: String in ENEMY_VULNERABILITIES:
		var enemy: VulnerabilityConfig = load(path) as VulnerabilityConfig
		var message: String = "%s: inimigo vulnerável %.2f s, próximo golpe do player em %.2f s"
		message = message % [path, enemy.duration, next_hit]
		assert_float(enemy.duration).override_failure_message(message).is_greater(next_hit)
