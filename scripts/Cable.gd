class_name Cable extends Control

onready var line : Line2D = $Outline/Line2D
onready var outline : Line2D = $Outline
onready var collision_polygon = $Area2D/CollisionPolygon2D
onready var mouse_stop_rect = $MouseStopper
export var undefined_color = Color.red
export var off_color = Color.gray
export var on_color = Color.yellow
export var hover_color = Color.cornflower

var connected_output = null
var connected_input = null

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
	
func set_start_point(point : Vector2):
	line.points[0] = point
	outline.points[0] = point
	collision_polygon.polygon[0] = Vector2(point.x - 22, point.y - 22)
	collision_polygon.polygon[1] = Vector2(point.x + 12, point.y + 12)

func adjust_color(state):
	line.default_color = undefined_color if state.is_undefined() else \
		(on_color if state.is_true() else off_color)

func get_start_point():
	return line.points[0]

func set_end_point(point : Vector2):
	line.points[1] = point
	outline.points[1] = point
	collision_polygon.polygon[2] = Vector2(point.x + 22, point.y + 22)
	collision_polygon.polygon[3] = Vector2(point.x - 12, point.y - 12)

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
	if connected_output != null:
		connected_output.remove_cable(self)
	if connected_input == null:
		return
	connected_input.connected_cable = null
	connected_input.set_state(TriState.State.UNDEFINED)

func set_z_index(new_index):
	outline.z_index = new_index
	print(new_index)
	if connected_input != null:
		connected_input.set_z_index(new_index + 1, -new_index - 1)
	if connected_output != null:
		connected_output.set_z_index(new_index + 1, -new_index - 1)

func _on_Area2D_mouse_entered():
	outline.default_color = hover_color

func _on_Area2D_mouse_exited():
	outline.default_color = Color.black
