class_name Cable extends Node2D

onready var line : Line2D = $Outline/Line2D
onready var outline : Line2D = $Outline
onready var collision_shape : CollisionPolygon2D = $Area2D/CollisionShape
var collision_rect : Rect2

export var undefined_color = Color.red
export var off_color = Color.gray
export var on_color = Color.yellow
export var hover_color = Color.cornflower
export var side_offset = 26 

var connected_output = null
var connected_input = null
var is_hovered = false
var node_count = 0

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
	calc_collision(outline.points[-2], outline.points[-1], node_count)

func calc_collision(start, end, offset = 0):
	var idx = offset * 4
	collision_shape.polygon.insert(idx, start + start.direction_to(end) * side_offset + \
		start.direction_to(end).rotated(deg2rad(-90)).normalized() * outline.width / 2)
	collision_shape.polygon.insert(idx + 1, start + start.direction_to(end) * side_offset + \
		start.direction_to(end).rotated(deg2rad(90)).normalized() * outline.width / 2)
	collision_shape.polygon.insert(idx + 2, end + end.direction_to(start) * side_offset + \
		start.direction_to(end).rotated(deg2rad(90)).normalized() * outline.width / 2)
	collision_shape.polygon.insert(idx + 3, end + end.direction_to(start) * side_offset + \
		start.direction_to(end).rotated(deg2rad(-90)).normalized() * outline.width / 2)

func is_point_inside(point) -> bool:
	return Geometry.is_point_in_polygon(point, collision_shape.polygon)

func connect_to(connection):
	if connection is Output:
		connect_output(connection)
	else:
		connect_input(connection)

func connect_input(input):
	connected_input = input
	set_end_point(input.global_position)
	input.connect("position_changed", self, "_on_input_position_changed")
	
func connect_output(output):
	connected_output = output
	set_start_point(output.global_position)
	output.connect("position_changed", self, "_on_output_position_changed")

func add_cable_node(cable_node):
	node_count += 1
	cable_node.idx = node_count
	cable_node.connection_type = "Input" if connected_input == null else "Output"
	line.points.insert(node_count, cable_node.global_position)
	outline.points.insert(node_count, cable_node.global_position)
	calc_collision(outline.points[node_count - 1], outline.points[node_count], node_count - 1)
	if line.points.size() > node_count + 1:
		calc_collision(outline.points[node_count], outline.points[node_count + 1], node_count)

func _on_input_position_changed(new_pos):
	set_end_point(new_pos)

func _on_output_position_changed(new_pos):
	set_start_point(new_pos)

func get_end_point():
	return line.points[-1]

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
	if connected_output != null:
		connected_output.remove_cable(self)
	if connected_input == null:
		return
	connected_input.connected_cable = null
	connected_input.set_state(TriState.State.UNDEFINED)
