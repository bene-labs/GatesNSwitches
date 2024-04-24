class_name Gate extends Node2D

signal clicked(Gate, offset)
signal released(Gate)
signal position_changed
signal z_index_changed(new_index)
signal destroy
signal destroyed(Gate)

var hover_color = Color.LIGHT_BLUE

var default_color

@onready var output = get_node_or_null("Output")
@onready var collision_shape = $Area2D/CollisionPolygon2D
@onready var image = $Sprite

var inputs = []
var is_hovered = false
var is_dragged = false
var drag_mode_queded = false

var sprite_z_index = z_index

func _ready():
	CursorCollision.register(self)
	default_color = image.modulate

	if output != null:
		output.is_standalone = false
		position_changed.connect(output._on_position_changed)
		z_index_changed.connect(output._on_z_index_changed)
		destroy.connect(output._on_destroy)
	
	if get_node_or_null("Inputs") == null:
		return
	for input in get_node("Inputs").get_children():
		inputs.append(input)
		input.is_standalone = false
		input.state_changed.connect(_on_input_changed)
		position_changed.connect(input._on_position_changed)
		z_index_changed.connect(input._on_z_index_changed)
		destroy.connect(input._on_destroy)
	call_deferred("_on_input_changed")

func _on_input_changed():
	pass

func _on_mouse_entered():
	image.modulate = hover_color
	is_hovered = true
	
func _on_mouse_exited():
	if drag_mode_queded:
		clicked.emit(self, global_position - get_global_mouse_position())
		drag_mode_queded = false
	image.modulate = default_color
	is_hovered = false

func set_dragged():
	is_dragged = true
	CursorCollision.lock()
	
func set_undragged():
	is_dragged = false
	CursorCollision.unlock()

func _input(event):
	if is_dragged and Input.is_action_just_released("gate"):
		emit_signal("released", self)
	
	if not is_hovered:
		return

	if Input.is_action_just_pressed("destroy") and not is_dragged:
		CursorCollision.unregister(self)
		emit_signal("destroy")
		call_deferred("queue_free")
	elif Input.is_action_just_pressed("gate") and not drag_mode_queded:
		drag_mode_queded = true
		await get_tree().create_timer(0.1).timeout
		try_start_drag_mode()
	
	if Input.is_action_just_pressed("rotate_gate"):
		rotate_counterclockwise()

func try_start_drag_mode():
	if not drag_mode_queded:
		return true
	drag_mode_queded = false
	if not is_hovered or not Input.is_action_pressed("gate"):
		return false
	
	emit_signal("clicked", self, global_position - get_global_mouse_position())
	return true

func update_position(value):
	position = value
	emit_signal("position_changed")

@warning_ignore("native_method_override")
func set_z_index(value):
	image.z_index = value
	sprite_z_index = value
	emit_signal("z_index_changed", value)

@warning_ignore("native_method_override")
func get_z_index():
	return sprite_z_index
	
func rotate_counterclockwise():
	rotate(deg_to_rad(90.0))
	update_position(position)
	
func is_point_inside(point):
	return Geometry2D.is_point_in_polygon(to_local(point), collision_shape.polygon)

func _exit_tree():
	emit_signal("destroyed", self)
