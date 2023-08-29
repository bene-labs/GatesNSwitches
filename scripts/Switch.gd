extends Gate

func _ready():
	output.set_state(TriState.State.FALSE)

func try_start_drag_mode():
	if not .try_start_drag_mode():
		image.animation = "on" if image.animation == "off" else "off"
		output.set_state(TriState.State.TRUE if image.animation == "on" else TriState.State.FALSE)
