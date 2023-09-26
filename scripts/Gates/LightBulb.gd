extends Gate

export var undefined_color = Color.red
export var off_color = Color.gray
export var on_color = Color.yellow

onready var sprite = $Bulb
onready var outline = $Sprite

func _on_input_changed():
	._on_input_changed()
	var state = inputs[0].state
	sprite.self_modulate = undefined_color if state.is_undefined() else \
		(on_color if state.is_true() else off_color)

func set_z_index(new_idx):
	.set_z_index(new_idx)
	outline.z_index = new_idx - 1
	sprite.z_index = new_idx
