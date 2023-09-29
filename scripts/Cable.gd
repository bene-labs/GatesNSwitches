class_name Cable extends Node2D

onready var line : Line2D = $Outline/Line2D
onready var outline : Line2D = $Outline
onready var collision_shape : CollisionPolygon2D = $Area2D/CollisionShape
var collision_rect : Rect2

export var undefined_color = Color.red
export var off_color = Color.gray
export var on_color = Color.yellow
export var hover_color = Color.cornflower
export var side_offset = 0

var connected_output = null
var connected_input = null
var started_from_input = false
var is_hovered = false
var node_count = 0
var nodes = []

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
	
func set_start_point(point : Vector2, update_collision = false):
	line.points[0] = point
	outline.points[0] = point
	if update_collision or connected_output != null:
		calc_collision(outline.points[0], outline.points[-1])

func get_start_point():
	return line.points[0]

func set_end_point(point : Vector2, update_collision = false):
	line.points[-1] = point
	outline.points[-1] = point
	if update_collision or connected_input != null:
		calc_collision(outline.points[-2], outline.points[-1], node_count)

func calc_collision(start, end, offset = 0):
	var idx = offset * 4
	var pol = collision_shape.polygon
	
	pol.resize(idx + 4)
	
	pol[idx] = start + start.direction_to(end) * side_offset + \
		start.direction_to(end).rotated(deg2rad(-90)).normalized() * outline.width / 2
	pol[idx + 1] = start + start.direction_to(end) * side_offset + \
		start.direction_to(end).rotated(deg2rad(90)).normalized() * outline.width / 2
	pol[idx + 2] = end + end.direction_to(start) * side_offset + \
		start.direction_to(end).rotated(deg2rad(90)).normalized() * outline.width / 2
	pol[idx + 3] = end + end.direction_to(start) * side_offset + \
		start.direction_to(end).rotated(deg2rad(-90)).normalized() * outline.width / 2
	if offset > 0 and offset == node_count:
		pol.resize(idx + 4 + node_count)
		for i in range(0, node_count):
			pol[idx + 4 + i] = pol[(node_count - (i + 1)) * 4 + 3]
	collision_shape.polygon = pol
	

func is_point_inside(point) -> bool:
	return Geometry.is_point_in_polygon(point, collision_shape.polygon)

func connect_to(connection):
	if connection is Cable_Node:
		set_end_point(connection.global_position)
	elif connection is Output:
		connect_output(connection)
	else:
		connect_input(connection)

func connect_input(input):
	if connected_output == null:
		started_from_input = true
	connected_input = input
	set_end_point(input.global_position, true)
	input.connect("position_changed", self, "_on_input_position_changed")
	
func connect_output(output):
	if connected_output == null:
		started_from_input = false
	connected_output = output
	set_start_point(output.global_position, true)
	output.connect("position_changed", self, "_on_output_position_changed")

func add_cable_node(cable_node):
	nodes.append(cable_node)
	cable_node.parent_cable = self
	node_count += 1
	cable_node.idx = node_count
	cable_node.connection_type = "Input" if connected_output == null else "Output"
	var points_temp = line.points
	points_temp.insert(node_count, cable_node.global_position)
	line.points = points_temp
	outline.points = points_temp
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
	for node in nodes:
		node.queue_free()
	if connected_output != null:
		connected_output.remove_cable(self)
	if connected_input == null:
		return
	connected_input.connected_cable = null
	connected_input.set_state(TriState.State.UNDEFINED)
