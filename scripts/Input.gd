class_name InputConnection extends Connection

signal destroyed(input)

var connected_output = null
var connected_cable : Cable = null
onready var cables = get_tree().get_nodes_in_group("Cables")[0]

func _ready():
	connect("clicked", self, "_on_Input_clicked")
	connect("released_over", self, "_on_Input_released_over")

func link(connection, cable):
	if connected_cable != null:
		connected_cable.queue_free()
	connected_output = connection
	connected_cable = cable
	set_state(connection.state.get_state())

func is_available():
	return true

func _on_Input_clicked(node):
	if connected_cable != null:
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

func _on_z_index_changed(new_index):
	._on_z_index_changed(new_index)
#	if weakref(connected_cable).get_ref():
#		connected_cable.set_z_index(new_index - 1)
	set_z_index(new_index)

func _on_destroy():
	if weakref(connected_cable).get_ref():
		connected_cable.queue_free()

func _exit_tree():
	emit_signal("destroyed", self)
