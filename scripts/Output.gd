class_name Output extends Connection

signal destroyed(output)

var connected_inputs = []
var connected_cables : Array = []

func _ready():
	set_state(TriState.State.TRUE)

func set_state(value):
	.set_state(value)
	for cable in connected_cables:
		cable.adjust_color(state)
	for input in connected_inputs:
		input.set_state(value)

func link(connection, cable, end_idx):
	connected_inputs.append(connection)
	connected_cables.append(cable)
	for cable in connected_cables:
		cable.adjust_color(state)

func remove_cable(cable):
	var idx_to_remove = connected_cables.find(cable)
	if idx_to_remove < 0:
		return
	
	connected_cables.remove(idx_to_remove)
	connected_inputs[idx_to_remove].connected_output = null
	connected_inputs.remove(idx_to_remove)

func is_available():
	return true

func _on_z_index_changed(new_index):
	._on_z_index_changed(new_index)
	for connected_cable in connected_cables:
		connected_cable.set_z_index(new_index - 1)
	set_z_index(new_index)

func _on_destroy():
	for connected_cable in connected_cables:
		if weakref(connected_cable).get_ref():
			connected_cable.queue_free()

func _exit_tree():
	emit_signal("destroyed", self)
