extends Gate

export var undefined_color = Color.red
export var off_color = Color.gray
export var on_color = Color.yellow

onready var sprite = $Bulb

func _on_Input_state_changed():
	var state = inputs[0].state
	sprite.self_modulate = undefined_color if state.is_undefined() else \
		(on_color if state.is_true() else off_color)

func set_z_index(new_idx):
	.set_z_index(new_idx)
	sprite.z_index = new_idx + 1
