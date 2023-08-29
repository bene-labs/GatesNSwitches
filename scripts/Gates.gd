extends Node2D

onready var gates = get_tree().get_nodes_in_group("Gate")
onready var cables = get_tree().get_nodes_in_group("Cables")[0]

onready var button_rect = $ColorRect
var buttons = []

var dragged_gate : Gate = null
var drag_offset = Vector2.ZERO
var is_mouse_movement = false

var max_z_index = 0

func _ready():
	for gate in gates:
		gate.connect("clicked", self, "_on_gate_clicked")
		gate.connect("released", self, "_on_gate_released")
	for button in button_rect.get_children():
		buttons.append(button)
		button.connect("gate_spawned", self, "_on_gate_spawned")

func _on_gate_clicked(gate : Gate, offset: Vector2):
	max_z_index += 2
	gate.set_z_index(max_z_index)
	gate.set_dragged()
	dragged_gate = gate
	drag_offset = offset
	
func _on_gate_released(gate: Gate):
	gate.set_undragged()
	dragged_gate = null

func _process(delta):
	if dragged_gate == null or not is_mouse_movement:
		return
	dragged_gate.set_position(get_global_mouse_position() + drag_offset)

func _input(event):
	is_mouse_movement = true if event is InputEventMouseMotion and event.relative else false 

func update_button_dimensions():
	for i in range(buttons.size()):
		buttons[i].rect_size = Vector2(button_rect.rect_size.x * 0.9,  button_rect.rect_size.y / 12.25)
		buttons[i].rect_position = Vector2(button_rect.rect_size.x * 0.05,  button_rect.rect_size.y / 11 * i)

func _on_gate_spawned(new_gate : Gate):
	gates.append(new_gate)
	new_gate.connect("clicked", self, "_on_gate_clicked")
	new_gate.connect("released", self, "_on_gate_released")
	for input in new_gate.inputs:
		cables.register_input(input)
	if new_gate.output != null:
		cables.register_output(new_gate.output)
	
