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
	#collision_shape.position = outline.points[0] + (outline.points[1] - outline.points[0]) / 2

	calc_collision(outline.points[0], outline.points[-1])
	#collision_shape.look_at(outline.points[1])
	#collision_shape.shape.extents.x = outline.points[0].distance_to(outline.points[1]) / 2
	#collision_shape.shape.extents.x -= side_offset

func get_start_point():
	return line.points[0]

func set_end_point(point : Vector2):
	line.points[1] = point
	outline.points[1] = point
	
	calc_collision(outline.points[0], outline.points[-1])
	
	#collision_shape.position = outline.points[0] + (outline.points[1] - outline.points[0]) / 2
	#collision_shape.look_at(outline.points[1])
	#collision_shape.shape.extents.x = outline.points[0].distance_to(outline.points[1]) / 2
	#collision_shape.shape.extents.x -= side_offset

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

func connect_to(connection : Connection):
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

func _on_input_position_changed(new_pos):
	set_end_point(new_pos)

func _on_output_position_changed(new_pos):
	set_start_point(new_pos)

func get_end_point():
	return line.points[1]

func _exit_tree():
	CursorCollision.unregister(self)
	if connected_output != null:
		connected_output.remove_cable(self)
	if connected_input == null:
		return
	connected_input.connected_cable = null
	connected_input.set_state(TriState.State.UNDEFINED)

func set_z_index(new_index):
	outline.z_index = new_index

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
