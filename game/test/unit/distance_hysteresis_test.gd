extends GdUnitTestSuite
## Perto ou longe com folga: entra no limite e só sai acima do limite mais a folga.

const THRESHOLD: float = 10.0
const HYSTERESIS: float = 0.5


func _near(was_near: bool, distance: float) -> bool:
	return DistanceHysteresis.is_near(was_near, distance, THRESHOLD, HYSTERESIS)


func test_far_becomes_near_at_threshold() -> void:
	assert_bool(_near(false, THRESHOLD + 0.1)).is_false()
	assert_bool(_near(false, THRESHOLD)).is_true()


func test_near_stays_until_beyond_threshold_plus_hysteresis() -> void:
	assert_bool(_near(true, THRESHOLD + 0.4)).is_true()
	assert_bool(_near(true, THRESHOLD + 0.5)).is_true()
	assert_bool(_near(true, THRESHOLD + 0.6)).is_false()
