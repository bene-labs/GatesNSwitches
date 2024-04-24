extends Node2D

signal active_cable_state_changed(is_active)

var cable_scene = preload("res://scenes/Cable.tscn")
var cable_connection_scene = preload("res://scenes/CableConnection.tscn")
var input_script_path = "res://scripts/Input.gd"
var output_script_path = "res://scripts/Output.gd"

var active_cable : Cable = null
var active_start_node = null

@onready var inputs = get_tree().get_nodes_in_group("Input")
@onready var outputs = get_tree().get_nodes_in_group("Output")
var cable_nodes = []

var is_input_required = false
var tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	for input in inputs:
		input.clicked.connect(_on_input_clicked)
		input.released_over.connect(_on_input_released)
		input.destroyed.connect(remove_input)
	for output in outputs:
		output.clicked.connect(_on_output_clicked)
		output.released_over.connect(_on_output_released)
		output.destroyed.connect(remove_output)
	for cable_node in cable_nodes:
		cable_node.clicked.connect(_on_cable_node_clicked)
		cable_node.released_over.connect(_on_cable_node_released)
		cable_node.destroyed.connect(remove_cable_node)
	
	emit_signal("active_cable_state_changed", false)
	
func register_input(input):
	inputs.append(input)
	input.clicked.connect(_on_input_clicked)
	input.released_over.connect(_on_input_released)
	input.destroyed.connect(remove_input)

func register_output(output):
	outputs.append(output)
	output.clicked.connect(_on_output_clicked)
	output.released_over.connect(_on_output_released)
	output.destroyed.connect(remove_output)

func register_cable_node(cable_node):
	cable_nodes.append(cable_node)
	cable_node.clicked.connect(_on_output_clicked)
	cable_node.released_over.connect(_on_output_released)
	cable_node.destroyed.connect(remove_output)
	
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
	active_cable_state_changed.emit(false)
	CursorCollision.remove_from_whitelist(input_script_path if is_input_required else output_script_path)

func create_new_cable(start_node):
	if active_cable != null:
		active_cable.queue_free()
		active_cable = null
	active_cable = cable_scene.instantiate()
	add_child(active_cable)
	active_cable.connect_to(start_node)
	#active_cable.outline.z_index = start_node.z_index - 1
	
	active_start_node = start_node
	active_cable_state_changed.emit(true)
	CursorCollision.add_to_whitelist(input_script_path if is_input_required else output_script_path)
	

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
	
func add_cable_connection():
	if active_cable == null:
		return
	for input in inputs:
		if input.is_point_inside(get_global_mouse_position()):
			remove_active_cable()
			return
	for output in outputs:
		if output.is_point_inside(get_global_mouse_position()):
			remove_active_cable()
			return
	var mouse_pos = get_global_mouse_position()
	var new_start_point = cable_connection_scene.instantiate()
	
	new_start_point.set_script(load(output_script_path if is_input_required else input_script_path))
	new_start_point.global_position = mouse_pos
	get_tree().root.add_child(new_start_point)
	if is_input_required:
		new_start_point.name = "Output"
		register_output(new_start_point)
		active_cable.connect_input(new_start_point)
		active_start_node.link(new_start_point, active_cable)
		new_start_point.state.value = active_start_node.state.value
	else:
		new_start_point.name = "Input"
		register_input(new_start_point)
		active_cable.connect_output(new_start_point)
		new_start_point.link_chained_input(active_start_node, active_cable)
		active_start_node.link(new_start_point, active_cable)
	
	CursorCollision.put_in_front(new_start_point)
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
	if active_cable != null and Input.is_action_just_released("cable"):
		if tween:
			tween.kill()
		tween = get_tree().create_tween()
		tween.tween_callback(add_cable_connection).set_delay(0.05)
		tween.play()
	
func _process(delta):
	if active_cable != null:
		active_cable.update_loose_point(get_global_mouse_position())
