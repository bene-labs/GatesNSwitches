extends Gate

func _on_input_changed():
	super._on_input_changed()
	
	if inputs[0].state.is_true() or inputs[1].state.is_true():
		output.set_state(TriState.State.FALSE)
	elif inputs[0].state.is_false() and inputs[1].state.is_false():
		output.set_state(TriState.State.TRUE)
	else:
		output.set_state(TriState.State.UNDEFINED)
