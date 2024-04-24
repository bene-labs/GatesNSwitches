class_name Connection extends Sprite2D

signal state_changed
signal clicked(node)
signal released_over(node)
signal position_changed(new_pos)

var collision_radius = 26.0
var undefined_color = Color.RED
var off_color = Color("545151")
var on_color = Color("241ec9")
var inactive_color = Color("b1e2f1")
var active_color = Color("65c2dd")

@onready var wire = get_node_or_null("InteractionPoint/Wire")
@onready var interactionSprite : Sprite2D = %InteractionPoint
@onready var base_scale = interactionSprite.scale

var is_hovered : bool = false
var is_active : bool = false
var is_standalone = true

var state = TriState.new()
var is_dragged = false
var drag_offset = Vector2.ZERO
var is_mouse_movement = false

func _ready():
	set_state(TriState.State.UNDEFINED)
	interactionSprite.self_modulate = inactive_color
	CursorCollision.register(self)

func set_state(value):
	match value:
		TriState.State.TRUE:
			self_modulate = on_color
		TriState.State.FALSE:
			self_modulate = off_color
		_:
			self_modulate = undefined_color
	if value == state.value:
		return
	state.value = value
	
	$DelayTimer.wait_time = Configs.simulation_speed
	$DelayTimer.start()
	await $DelayTimer.timeout
	state_changed.emit()

func is_point_inside(point):
	return global_position.distance_to(point) <= collision_radius
	
func _on_mouse_entered():
	interactionSprite.scale = base_scale * 1.15
	is_hovered = true
	
func _on_mouse_exited():
	interactionSprite.scale = base_scale
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
	
	is_mouse_movement = true if event is InputEventMouseMotion and event.relative else false
	
	if Input.is_action_just_pressed("cable"):
		emit_signal("clicked", self)
	elif is_active and Input.is_action_just_released("cable"):
		emit_signal("released_over", self)
	elif is_standalone and Input.is_action_just_pressed("drag_connection"):
		is_dragged = true
		drag_offset = global_position - get_global_mouse_position()
		CursorCollision.lock()
	elif is_dragged and Input.is_action_just_released("drag_connection"):
		is_dragged = false
		CursorCollision.unlock()

func _process(delta):
	if !is_dragged or !is_mouse_movement:
		return
	set_position(get_global_mouse_position() + drag_offset)
	_on_position_changed()
	
func is_available():
	return false

func _on_z_index_changed(new_index):
	pass

@warning_ignore("native_method_override")
func set_z_index(value, wire_offset = 0):
	z_index = value
	if wire == null:
		return
	wire.z_index = wire_offset

	
func _on_position_changed():
	emit_signal("position_changed", global_position)

func _exit_tree():
	CursorCollision.unregister(self)
