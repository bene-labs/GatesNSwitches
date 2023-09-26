class_name Switch extends Gate

func _ready():
	output.set_state(TriState.State.FALSE)

func toggle():
	image.animation = "on" if image.animation == "off" else "off"
	output.set_state(TriState.State.TRUE if image.animation == "on" else TriState.State.FALSE)

func try_start_drag_mode():
	if not .try_start_drag_mode():
		toggle()

func _process(delta):
	if drag_mode_queded and Input.is_action_just_released("gate"):
		toggle()
		drag_mode_queded = false
