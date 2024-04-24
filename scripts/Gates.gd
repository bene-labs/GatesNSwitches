extends Control

signal drag_toggled(new_state)

@onready var gates = get_tree().get_nodes_in_group("Gate")
@onready var cables = get_tree().get_nodes_in_group("Cables")[0]

@onready var button_rect = $ColorRect
var buttons = []

var dragged_gate : Gate = null
var drag_offset = Vector2.ZERO
var is_mouse_movement = false

func _ready():
	for gate in gates:
		gate.clicked.connect(_on_gate_clicked)
		gate.released.connect(_on_gate_released)
		gate.destroyed.connect(_on_gate_destroyed)
	call_deferred("apply_gate_z_index")
	for button in button_rect.get_children():
		buttons.append(button)
		button.gate_spawned.connect(_on_gate_spawned)

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
	emit_signal("drag_toggled", true)

func _on_gate_released(gate: Gate):
	gate.set_undragged()
	dragged_gate = null
	emit_signal("drag_toggled", false)

func _on_gate_destroyed(gate):
	gates.erase(gate)

func _process(delta):
	if dragged_gate == null or not is_mouse_movement:
		return
	dragged_gate.update_position(dragged_gate.get_global_mouse_position() + drag_offset)

func _input(event):
	is_mouse_movement = true if event is InputEventMouseMotion and event.relative else false

func update_button_dimensions():
	for i in range(buttons.size()):
		buttons[i].size = Vector2(button_rect.size.x * 0.9,  button_rect.size.y / (buttons.size() + 1.25) )
		buttons[i].global_position = Vector2(button_rect.size.x * 0.05,  button_rect.size.y / buttons.size() * i)

func _on_gate_spawned(new_gate : Gate):
	gates.append(new_gate)
	new_gate.clicked.connect(_on_gate_clicked)
	new_gate.released.connect(_on_gate_released)
	new_gate.destroyed.connect(_on_gate_destroyed)
	for input in new_gate.inputs:
		cables.register_input(input)
	if new_gate.output != null:
		cables.register_output(new_gate.output)
	
