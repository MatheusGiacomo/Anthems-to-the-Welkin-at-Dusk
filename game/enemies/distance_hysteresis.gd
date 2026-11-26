class_name DistanceHysteresis
extends RefCounted
## Regra pura de "perto ou longe" com folga, usada pelos inimigos para trocar de modo pela
## distância sem ficar alternando quando o alvo para em cima do limite.


## Devolve se o alvo a `distance` conta como perto. Quem estava longe (`was_near` falso) passa a
## perto a até `threshold`; quem estava perto só volta a longe acima de `threshold` + `hysteresis`.
static func is_near(was_near: bool, distance: float, threshold: float, hysteresis: float) -> bool:
	if was_near:
		return distance <= threshold + hysteresis
	return distance <= threshold
