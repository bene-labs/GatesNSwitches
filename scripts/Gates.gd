extends Node2D

onready var gates = get_tree().get_nodes_in_group("Gate")
onready var cables = get_tree().get_nodes_in_group("Cables")[0]

onready var button_rect = $ColorRect
var buttons = []

var dragged_gate : Gate = null
#var hovered_element = null
var drag_offset = Vector2.ZERO
var is_mouse_movement = false


func _ready():
	for gate in gates:
		gate.connect("clicked", self, "_on_gate_clicked")
		gate.connect("released", self, "_on_gate_released")
		gate.connect("destroyed", self, "_on_gate_destroyed")
	call_deferred("apply_gate_z_index")
	for button in button_rect.get_children():
		buttons.append(button)
		button.connect("gate_spawned", self, "_on_gate_spawned")

func put_gate_in_front(gate: Gate):
	gates.erase(gate)
	gates.push_front(gate)
	apply_gate_z_index()
	CursorCollision.update_order()

func apply_gate_z_index():
	var z_index = gates.size() * 3
	for gate in gates:
		gate.set_z_index(z_index)
		z_index -= 3

func _on_gate_clicked(gate : Gate, offset: Vector2):
	put_gate_in_front(gate)
	dragged_gate = gate
	drag_offset = offset
	gate.set_dragged()

func _on_gate_released(gate: Gate):
	gate.set_undragged()
	dragged_gate = null

func _on_gate_destroyed(gate):
	gates.erase(gate)

func _process(delta):
	if dragged_gate == null or not is_mouse_movement:
		return
	dragged_gate.set_position(get_global_mouse_position() + drag_offset)

#func hover_element(element):
#	if element == hovered_element:
#		return
#	if hovered_element != null:
#		hovered_element._on_mouse_exited()
#	element._on_mouse_entered()
#	hovered_element = element

#func try_hover_cables(gate: Gate, mouse_pos) -> bool:
#	for input in gate.inputs:
#		var cable = input.connected_cable
#		if cable != null and cable.is_point_inside(mouse_pos):
#			hover_element(cable)
#			return true
#
#	if gate.output == null:
#		return false
#	for cable in gate.output.connected_cables:
#		if cable.is_point_inside(mouse_pos):
#			hover_element(cable)
#			return true
#
#	return false

func _input(event):
	is_mouse_movement = true if event is InputEventMouseMotion and event.relative else false
#	if not is_mouse_movement or dragged_gate != null:
#		return
#	var mouse_pos = get_global_mouse_position()
#	for gate in gates:
#		if gate.is_point_inside(mouse_pos):
#			hover_element(gate)
#			return
#		elif try_hover_cables(gate, mouse_pos):
#			return
#
#	if hovered_element != null:
#		hovered_element._on_mouse_exited()
#		hovered_element = null

func update_button_dimensions():
	for i in range(buttons.size()):
		buttons[i].rect_size = Vector2(button_rect.rect_size.x * 0.9,  button_rect.rect_size.y / (buttons.size() + 1.25) )
		buttons[i].rect_position = Vector2(button_rect.rect_size.x * 0.05,  button_rect.rect_size.y / buttons.size() * i)

func _on_gate_spawned(new_gate : Gate):
	gates.append(new_gate)
	new_gate.connect("clicked", self, "_on_gate_clicked")
	new_gate.connect("released", self, "_on_gate_released")
	new_gate.connect("destroyed", self, "_on_gate_destroyed")
	for input in new_gate.inputs:
		cables.register_input(input)
	if new_gate.output != null:
		cables.register_output(new_gate.output)
	
