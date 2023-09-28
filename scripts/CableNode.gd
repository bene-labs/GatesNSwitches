class_name Cable_Node extends Sprite

signal state_changed
signal clicked(node)
signal released_over(node)
signal position_changed(cable_node)
signal destroyed(cable_node)

export var collision_radius = 26.0
export var undefined_color = Color.red
export var off_color = Color("545151")
export var on_color = Color("241ec9")
export var inactive_color = Color("b1e2f1")
export var active_color = Color("65c2dd")
onready var interactionSprite : Sprite = $Outline

var is_hovered : bool = false
var is_active : bool = false
var connection_type = "Input"

var connected_inputs = []
var connected_cables : Array = []

var state = TriState.new()
var idx = 0

func _ready():
	set_state(TriState.State.UNDEFINED)
	interactionSprite.self_modulate = inactive_color
	CursorCollision.register(self)

func link(connection, cable):
	if connection_type == "Input" and connected_cables.size() != 0:
		connected_cables[0].queue_free()
		connected_cables.clear()
	connected_inputs.append(connection)
	connected_cables.append(cable)
	for cable in connected_cables:
		cable.adjust_color(state)

func set_state(value):
	if value != state.get_state():
		state.set_state(value)
		emit_signal("state_changed")
	else:
		state.set_state(value)
	self_modulate = undefined_color if state.is_undefined() else \
		(on_color if state.is_true() else off_color)

func is_point_inside(point):
	return global_position.distance_to(point) <= collision_radius
	
func _on_mouse_entered():
	interactionSprite.scale = Vector2(1.15, 1.15)
	is_hovered = true
	
func _on_mouse_exited():
	interactionSprite.scale = Vector2.ONE
	is_hovered = false
	
func set_active():
	is_active = true
	interactionSprite.self_modulate = active_color
	
func set_inactive():
	is_active = false
	interactionSprite.self_modulate = inactive_color

func _input(event):
	if not is_hovered:
		return
	
	if Input.is_action_just_pressed("cable"):
		emit_signal("clicked", self)
	elif is_active and Input.is_action_just_released("cable"):
		emit_signal("released_over", self)

func is_available():
	return false

func _on_z_index_changed(new_index):
	pass

func set_z_index(value, wire_offset = 0):
	z_index = value

func get_z_index():
	return z_index
	
func _on_position_changed():
	emit_signal("position_changed", self)

func _exit_tree():
	CursorCollision.unregister(self)
	emit_signal("destroyed", self)
