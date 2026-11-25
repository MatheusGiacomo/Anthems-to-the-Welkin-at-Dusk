extends GdUnitTestSuite
## Máquina de estados: entrada e saída dos estados e repasse do fim só do estado atual.


class RecordingState:
	extends State

	var events: Array[String] = []

	func enter() -> void:
		events.append("enter")

	func exit() -> void:
		events.append("exit")


class RecordingMachine:
	extends StateMachine

	var finished_reasons: Array[int] = []

	func _on_current_finished(_state: State, reason: int) -> void:
		finished_reasons.append(reason)


var _machine: RecordingMachine
var _first: RecordingState
var _second: RecordingState


func before_test() -> void:
	_machine = auto_free(RecordingMachine.new())
	_first = RecordingState.new()
	_second = RecordingState.new()
	_machine.add_child(_first)
	_machine.add_child(_second)
	add_child(_machine)


func test_transition_exits_current_and_enters_next() -> void:
	_machine.transition_to(_first)
	_machine.transition_to(_second)
	assert_array(_first.events).is_equal(["enter", "exit"])
	assert_array(_second.events).is_equal(["enter"])
	assert_object(_machine.current).is_same(_second)


func test_transition_to_same_state_reenters() -> void:
	_machine.transition_to(_first)
	_machine.transition_to(_first)
	assert_array(_first.events).is_equal(["enter", "exit", "enter"])


func test_only_current_state_finishing_is_forwarded() -> void:
	_machine.transition_to(_first)
	_second.finished.emit(7)
	_first.finished.emit(3)
	assert_array(_machine.finished_reasons).is_equal([3])
