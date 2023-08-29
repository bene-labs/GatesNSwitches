class_name Gate extends Node2D

signal clicked(Gate, offset)
signal released(Gate)
signal position_changed
signal z_index_changed(new_index)
signal destroy

export var hover_color = Color.lightblue
var default_color

onready var output : Output = get_node_or_null("Output")
onready var collision = $Area2D
onready var image = $Sprite

var inputs = []
var is_hovered = false
var is_dragged = false
var drag_mode_queded = false

func _ready():
	default_color = image.modulate
	
	collision.connect("mouse_entered", self, "_on_mouse_entered")
	collision.connect("mouse_exited", self, "_on_mouse_exited")
	
	if output != null:
		connect("position_changed", output, "_on_position_changed")
		connect("z_index_changed", output, "_on_z_index_changed")
		connect("destroy", output, "_on_destroy")
	
	if get_node_or_null("Inputs") == null:
		return
	for input in get_node("Inputs").get_children():
		inputs.append(input)
		input.connect("state_changed", self, "_on_input_changed")
		connect("position_changed", input, "_on_position_changed")
		connect("z_index_changed", input, "_on_z_index_changed")
		connect("destroy", input, "_on_destroy")
	_on_input_changed()

func _on_input_changed():
	pass

func _on_mouse_entered():
	image.modulate = hover_color
	is_hovered = true
	
func _on_mouse_exited():
	image.modulate = default_color
	is_hovered = false

func set_dragged():
	is_dragged = true
	
func set_undragged():
	is_dragged = false

func _input(event):
	if is_dragged and Input.is_action_just_released("gate"):
		emit_signal("released", self)
	
	if not is_hovered:
		return

	if Input.is_action_just_pressed("destroy"):
		emit_signal("destroy")
		call_deferred("queue_free")

	elif Input.is_action_just_pressed("gate") and not drag_mode_queded:
		drag_mode_queded = true
		yield(get_tree().create_timer(0.1), "timeout")
		try_start_drag_mode()

func try_start_drag_mode():
	drag_mode_queded = false
	if not is_hovered or not Input.is_action_pressed("gate"):
		return false
	
	emit_signal("clicked", self, global_position - get_global_mouse_position())
	return true

func set_position(value):
	position = value
	emit_signal("position_changed")

func set_z_index(value):
	image.z_index = value
	emit_signal("z_index_changed", value)
