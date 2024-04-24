class_name InputConnection extends Connection

signal destroyed(input)

var connected_output = null
var connected_input = null
var connected_cable = null
var extra_cable = null
@onready var cables = get_tree().get_nodes_in_group("Cables")[0]


func _ready():
	super._ready()
	clicked.connect(_on_Input_clicked)
	released_over.connect(_on_Input_released_over)

func set_state(value):
	super.set_state(value)
	if weakref(extra_cable).get_ref():
		extra_cable.adjust_color(state)
	if  weakref(connected_input).get_ref() and connected_input.connected_cable == extra_cable:
		connected_input.set_state(value)

func link_chained_input(input, cable):
	if connected_cable != null:
		connected_cable.queue_free()
	if extra_cable != null:
		extra_cable.queue_free()
	connected_input = input
	extra_cable = cable
	set_state(TriState.State.UNDEFINED)

func link(connection, cable):
	if connected_cable != null:
		connected_cable.queue_free()
		connected_cable = null
	if !is_standalone and extra_cable != null:
		extra_cable.queue_free()
	connected_output = connection
	connected_cable = cable
	#print("connected '", connection.get_path(), "' with '", get_path(), "' => state: ", connection.state.value)
	set_state(connection.state.value)

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

func _on_z_index_changed(new_index):
	super._on_z_index_changed(new_index)
#	if weakref(connected_cable).get_ref():
#		connected_cable.set_z_index(new_index - 1)
	set_z_index(new_index)

func _on_destroy():
	if weakref(connected_cable).get_ref():
		connected_cable.queue_free()

func _exit_tree():
	super._exit_tree()
	emit_signal("destroyed", self)
