class_name Cable extends Node2D

onready var line : Line2D = $Outline/Line2D
onready var outline : Line2D = $Outline
onready var collision_shape : CollisionPolygon2D = $Area2D/CollisionShape
var collision_rect : Rect2

export var undefined_color = Color.red
export var off_color = Color.gray
export var on_color = Color.yellow
export var hover_color = Color.cornflower
export var side_offset = 5

var connected_output = null
var connected_input = null
var is_hovered = false

var has_started_from_input = false

func _ready():
	CursorCollision.register(self)

func update_loose_point(position) -> bool:
	if connected_output == null:
		set_start_point(position)
	elif connected_input == null:
		set_end_point(position)
	else:
		return false
	return true

func set_point(node):
	set_start_point(node.global_position) if node is Output else set_end_point(node.global_position)

func adjust_color(state):
	line.default_color = undefined_color if state.is_undefined() else \
		(on_color if state.is_true() else off_color)
	
func set_start_point(point : Vector2):
	line.points[0] = point
	outline.points[0] = point
	
	calc_collision(outline.points[0], outline.points[-1])

func get_start_point():
	return line.points[0]

func set_end_point(point : Vector2):
	line.points[-1] = point
	outline.points[-1] = point
	calc_collision(outline.points[-2], outline.points[-1])

func calc_collision(start, end):
	collision_shape.polygon[0] = start + start.direction_to(end) * side_offset + \
		start.direction_to(end).rotated(deg2rad(-90)).normalized() * outline.width / 2
	collision_shape.polygon[1] = start + start.direction_to(end) * side_offset + \
		start.direction_to(end).rotated(deg2rad(90)).normalized() * outline.width / 2
	collision_shape.polygon[2] = end + end.direction_to(start) * side_offset + \
		start.direction_to(end).rotated(deg2rad(90)).normalized() * outline.width / 2
	collision_shape.polygon[3] = end + end.direction_to(start) * side_offset + \
		start.direction_to(end).rotated(deg2rad(-90)).normalized() * outline.width / 2

func is_point_inside(point) -> bool:
	return Geometry.is_point_in_polygon(point, collision_shape.polygon)

func connect_to(connection):
	if connection is Output:
		connect_output(connection)
	else:
		connect_input(connection)

func connect_input(input):
	if connected_output == null:
		has_started_from_input = true
	connected_input = input
	set_end_point(input.global_position)
	input.connect("position_changed", self, "_on_input_position_changed")
	
func connect_output(output):
	if connected_input == null:
		has_started_from_input = false
	connected_output = output
	set_start_point(output.global_position)
	output.connect("position_changed", self, "_on_output_position_changed")

func _on_input_position_changed(new_pos):
	set_end_point(new_pos)

func _on_output_position_changed(new_pos):
	set_start_point(new_pos)

func get_end_point():
	return line.points[1]


func set_z_index(new_index):
	outline.z_index = new_index
#	if connected_input != null:
#		connected_input.set_z_index(new_index + 1)
#	if connected_output != null:
#		connected_output.set_z_index(new_index + 1)

func get_z_index():
	return outline.z_index

func _on_mouse_entered():
	outline.default_color = hover_color
	is_hovered = true

func _on_mouse_exited():
	outline.default_color = Color.black
	is_hovered = false

func _input(event):
	if not is_hovered:
		return
	if Input.is_action_just_pressed("destroy"):
		queue_free()

func _exit_tree():
	CursorCollision.unregister(self)
	if weakref(connected_output).get_ref():
		if connected_output is InputConnection:
			if connected_output.connected_cable != null:
				connected_output.connected_cable.queue_free()
			connected_output.queue_free()
			return
		else:
			connected_output.remove_cable(self)
	if !weakref(connected_input).get_ref() or ("connected_cable" in connected_input and connected_input.connected_cable != self):
		return
	if connected_input is Output:
		connected_input.remove_cable(self)
		connected_input.delete_all_cables()
		connected_input.queue_free()
		return
	connected_input.connected_cable = null
	connected_input.set_state(TriState.State.UNDEFINED)
