extends Gate

var undefined_color = Color.RED
var off_color = Color("545151")
var on_color = Color("241ec9")

@onready var sprite = $Bulb
@onready var outline = $Sprite


func _on_input_changed():
	super._on_input_changed()
	var state = inputs[0].state
	match state.value:
		TriState.State.TRUE:
			sprite.self_modulate = on_color
		TriState.State.FALSE:
			sprite.self_modulate = off_color
		_:
			sprite.self_modulate = undefined_color


func set_z_index(new_idx):
	super.set_z_index(new_idx)
	outline.z_index = new_idx - 1
	sprite.z_index = new_idx
