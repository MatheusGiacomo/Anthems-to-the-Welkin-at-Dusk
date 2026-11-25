class_name MeleeBehaviorRules
extends RefCounted
## Regras puras do combate corpo a corpo dos inimigos: qual modo seguir pela distância, depois de
## uma investida e depois da vulnerabilidade, e como se mover na cautela.

enum Mode { CHASE, CAUTION, LUNGE }
enum CautionMove { ADVANCE, STRAFE, RETREAT }
## O que aconteceu na investida. Ser atingido não aparece aqui: interrompe a investida.
enum LungeResult { NONE, HIT_TARGET, BLOCKED, CLASHED }


## Devolve o modo pela distância, partindo de `current` (`CHASE` ou `CAUTION`): a aproximação vira
## cautela a `approach_distance`; a cautela só volta à aproximação acima dela mais a folga.
static func distance_mode(current: Mode, distance: float, config: MeleeBehaviorConfig) -> Mode:
	if current == Mode.CHASE:
		return Mode.CAUTION if distance <= config.approach_distance else Mode.CHASE
	var give_up_distance: float = config.approach_distance + config.distance_hysteresis
	return Mode.CHASE if distance > give_up_distance else Mode.CAUTION


## Devolve o modo depois de uma investida completa: acertou o alvo, investe de novo; foi defendida
## ou trombou, cautela; senão, investe de novo se o alvo está mais perto que Y, ou cautela.
static func after_lunge(result: LungeResult, distance: float, config: MeleeBehaviorConfig) -> Mode:
	match result:
		LungeResult.HIT_TARGET:
			return Mode.LUNGE
		LungeResult.BLOCKED, LungeResult.CLASHED:
			return Mode.CAUTION
	return Mode.LUNGE if distance < config.caution_distance else Mode.CAUTION


## Devolve o modo ao sair da vulnerabilidade (inclusive de uma investida interrompida): cautela se
## o alvo está perto, aproximação se não.
static func after_stagger(distance: float, config: MeleeBehaviorConfig) -> Mode:
	return distance_mode(Mode.CAUTION, distance, config)


## Devolve como se mover na cautela: avança acima de Y + tolerância, recua abaixo de Y e circula
## entre os dois.
static func caution_move(distance: float, config: MeleeBehaviorConfig) -> CautionMove:
	if distance > config.caution_distance + config.caution_tolerance:
		return CautionMove.ADVANCE
	if distance < config.caution_distance:
		return CautionMove.RETREAT
	return CautionMove.STRAFE


## Devolve se o tempo na cautela conta para a investida: alvo a até Y + tolerância (mais perto
## também conta, para o alvo não evitar a investida colando no inimigo).
static func counts_toward_lunge(distance: float, config: MeleeBehaviorConfig) -> bool:
	return distance <= config.caution_distance + config.caution_tolerance


## Devolve quantos metros a investida avança para o golpe alcançar um alvo a `distance`: até ficar
## a `strike_reach` dele, sem passar de `max_lunge_distance` nem recuar.
static func lunge_distance(distance: float, config: MeleeBehaviorConfig) -> float:
	return clampf(distance - config.strike_reach, 0.0, config.max_lunge_distance)
