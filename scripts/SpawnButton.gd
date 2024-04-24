extends Button

signal gate_spawned(gate)

@export var gate_prefab : PackedScene

func _ready():
	button_down.connect(_on_button_down)

func _on_button_down():
	var ctrans = get_canvas_transform()
	var view_size = get_viewport_rect().size / ctrans.get_scale()
	
	var min_pos = -ctrans.get_origin() / ctrans.get_scale()
	var max_pos = min_pos + view_size
	
	var new_gate = gate_prefab.instantiate()
	new_gate.global_position = get_global_mouse_position()
#	new_gate.global_position = Vector2(rand_range(min_pos.x + view_size.x * 0.2, max_pos.x - view_size.x * 0.01),
#		 rand_range(min_pos.y + view_size.y * 0.01, max_pos.y - + view_size.y * 0.01))
	get_tree().root.add_child(new_gate)
	emit_signal("gate_spawned", new_gate)
	new_gate.emit_signal("clicked", new_gate, Vector2.ZERO)
	
