class_name InputConnection extends Connection

signal destroyed(input)

var connected_output : Output = null
var connected_cable : Cable = null
onready var cables = get_tree().get_nodes_in_group("Cables")[0]
var connected_cable_end_idx = 0

func link(connection, cable, end_idx):
	if weakref(connected_cable).get_ref():
		connected_cable.queue_free()
	connected_output = connection
	connected_cable = cable
	connected_cable_end_idx = end_idx
	connected_cable.connected_input = self
	set_state(connection.state.get_state())

func is_available():
	return true


func _on_Input_clicked(node):
	if weakref(connected_cable).get_ref():
		connected_cable.queue_free()
		connected_cable = null
		connected_output = null
		set_state(TriState.State.UNDEFINED)


func _on_Input_released_over(node):
	if weakref(connected_cable).get_ref():
		return
	
	if connected_cable != null:
		connected_cable.queue_free()
		connected_cable = null
		connected_output = null

func _on_position_changed():
	if connected_cable == null:
		return
	
	connected_cable.set_point_by_index(global_position, connected_cable_end_idx)

func _on_z_index_changed(new_index):
	._on_z_index_changed(new_index)
	if weakref(connected_cable).get_ref():
		connected_cable.set_z_index(new_index - 1)
	set_z_index(new_index)

func _on_destroy():
	if weakref(connected_cable).get_ref():
		connected_cable.queue_free()
		
func _exit_tree():
	emit_signal("destroyed", self)
