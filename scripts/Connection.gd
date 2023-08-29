class_name Connection extends Area2D

signal state_changed
signal clicked(node)
signal released_over(node)
signal position_changed(new_pos)

export var undefined_color = Color.red
export var off_color = Color.gray
export var on_color = Color.yellow
export var inactive_color = Color.beige
export var active_color = Color.blue

onready var sprite : Sprite = $Input
onready var wire = $Input/InteractionPoint/Wire
onready var interactionSprite : Sprite = $Input/InteractionPoint
onready var collision : CollisionShape2D = $CollisionShape2D

var is_hovered : bool = false
var is_active : bool = false

var state = TriState.new()


func _ready():
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	set_state(TriState.State.UNDEFINED)
	interactionSprite.self_modulate = inactive_color

func set_state(value):
	if value != state.get_state():
		state.set_state(value)
		emit_signal("state_changed")
	else:
		state.set_state(value)
	sprite.self_modulate = undefined_color if state.is_undefined() else \
		(on_color if state.is_true() else off_color)

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
	sprite.z_index = value
	wire.z_index = wire_offset

func _on_position_changed():
	emit_signal("position_changed", global_position)
