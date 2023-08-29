class_name TriState extends Resource

signal state_changed

enum State {
	TRUE,
	FALSE,
	UNDEFINED
}

var state = State.UNDEFINED setget set_state, get_state

func set_state(value):
	state = value
	emit_signal("state_changed")

func get_state():
	return state

func is_undefined():
	return state == State.UNDEFINED
	
func is_true():
	return state == State.TRUE
	
func is_false():
	return state == State.FALSE
	
func equals(other):
	return State.UNDEFINED if \
	state == State.UNDEFINED or other.state == State.UNDEFINED else \
		(State.TRUE if state == other.state else State.FALSE)
