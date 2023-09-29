extends Node2D

signal active_cable_state_changed(is_active)

export var cable_scene = preload("res://scenes/Cable.tscn")
export var cable_node_scene = preload("res://scenes/CableNode.tscn")

var active_cable : Cable = null
var active_start_node = null

onready var inputs = get_tree().get_nodes_in_group("Input")
onready var outputs = get_tree().get_nodes_in_group("Output")
onready var cable_nodes = get_tree().get_nodes_in_group("CableNode")

var is_input_required = false
onready var tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	for input in inputs:
		input.connect("clicked", self, "_on_input_clicked")
		input.connect("released_over", self, "_on_input_released")
		input.connect("destroyed", self, "remove_input")
	for output in outputs:
		output.connect("clicked", self, "_on_output_clicked")
		output.connect("released_over", self, "_on_output_released")
		output.connect("destroyed", self, "remove_output")
	for cable_node in cable_nodes:
		cable_node.connect("clicked", self, "_on_cable_node_clicked")
		cable_node.connect("released_over", self, "_on_cable_node_released")
		cable_node.connect("destroyed", self, "remove_cable_node")
	
	emit_signal("active_cable_state_changed", false)
	
func register_input(input):
	inputs.append(input)
	input.connect("clicked", self, "_on_input_clicked")
	input.connect("released_over", self, "_on_input_released")
	input.connect("destroyed", self, "remove_input")

func register_output(output):
	outputs.append(output)
	output.connect("clicked", self, "_on_output_clicked")
	output.connect("released_over", self, "_on_output_released")
	output.connect("destroyed", self, "remove_output")

func register_cable_node(cable_node):
	cable_nodes.append(cable_node)
	cable_node.connect("clicked", self, "_on_cable_node_clicked")
	cable_node.connect("released_over", self, "_on_cable_node_released")
	cable_node.connect("destroyed", self, "remove_cable_node")

func remove_input(input):
	inputs.erase(input)
	
func remove_output(output):
	outputs.erase(output)

func remove_cable_node(cable_node):
	cable_nodes.erase(cable_node)

func _on_input_clicked(node : Node2D):
	is_input_required = false
	show_available_connections()
	create_new_cable(node)

func _on_output_clicked(node):
	is_input_required = true
	show_available_connections()
	create_new_cable(node)
	
func _on_cable_node_clicked(node):
	is_input_required = node.connection_type == "Input"
	show_available_connections()
	create_new_cable(node)

func show_available_connections():
	if is_input_required:
		for input in inputs:
			if input.is_available():
				input.set_active()
	else:
		for output in outputs:
			if output.is_available():
				output.set_active()

func hide_available_connections():
	for input in inputs:
		input.set_inactive()
	for output in outputs:
		output.set_inactive()
	emit_signal("active_cable_state_changed", false)
	CursorCollision.remove_from_whitelist("Input" if is_input_required else "Output")

func create_new_cable(start_node):
	if active_cable != null:
		active_cable.queue_free()
		active_cable = null
	active_cable = cable_scene.instance()
	add_child(active_cable)
	active_cable.connect_to(start_node)
	#active_cable.outline.z_index = start_node.z_index - 1
	
	active_start_node = start_node
	emit_signal("active_cable_state_changed", true)
	CursorCollision.add_to_whitelist("Input" if is_input_required else "Output")
	

func _on_input_released(over):
	if not is_input_required:
		remove_active_cable()
		return
	link_active_cable(over)
	
func _on_output_released(over):
	if is_input_required:
		remove_active_cable()
		return
	link_active_cable(over)
	
func _on_cable_node_released(over):
	if is_input_required == (over.connection_type == "Input"):
		remove_active_cable()
		return
	link_active_cable(over)
	
func link_active_cable(end_point):
	active_cable.connect_to(end_point)
	active_start_node.link(end_point, active_cable)
	end_point.link(active_start_node, active_cable)
	active_cable = null
	hide_available_connections()
	
func remove_active_cable():
	if active_cable == null:
		return
	active_cable.queue_free()
	active_cable = null
	active_start_node = null
	hide_available_connections()

func is_cable_active():
	return active_cable != null

func _input(event):
	if Input.is_action_just_released("cable"):
		tween.interpolate_callback(self, 0.05, "create_cable_node")
		tween.start()

func create_cable_node():
	if active_cable == null:
		return
	var new_node = cable_node_scene.instance()
	new_node.position = get_global_mouse_position()
	get_tree().root.add_child(new_node)
	active_cable.add_cable_node(new_node)
	register_cable_node(new_node)
	active_cable = null
	hide_available_connections()
	
func _process(delta):
	if active_cable != null:
		assert(active_cable.update_loose_point(get_global_mouse_position()), "ERROR: Active Cable has no losse end!")
