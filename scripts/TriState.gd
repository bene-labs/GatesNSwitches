class_name TriState extends Resource

signal state_changed

enum State {
	TRUE,
	FALSE,
	UNDEFINED
}

var value : State = State.UNDEFINED:
	set(state): 
		value = state
		emit_signal("state_changed")
	get: return value


func is_undefined():
	return value == State.UNDEFINED


func is_true():
	return value == State.TRUE


func is_false():
	return value == State.FALSE


func equals(other):
	return State.UNDEFINED if \
	value == State.UNDEFINED or other.value == State.UNDEFINED else \
		(State.TRUE if value == other.value else State.FALSE)
