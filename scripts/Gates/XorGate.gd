extends Gate

func _on_input_changed():
	super._on_input_changed()
	
	match inputs[0].state.equals(inputs[1].state):
		TriState.State.FALSE:
			output.set_state(TriState.State.TRUE)
		TriState.State.TRUE:
			output.set_state(TriState.State.FALSE)
		_:
			output.set_state(TriState.State.UNDEFINED)


