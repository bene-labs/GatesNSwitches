class_name Cable extends Area2D

onready var line : Line2D = $Line2D
onready var outline : Line2D = $Outline
onready var collision = $CollisionShape2D
export var undefined_color = Color.red
export var off_color = Color.gray
export var on_color = Color.yellow

var connected_output = null
var connected_input = null

	
func set_start_point(point : Vector2):
	line.points[0] = point
	outline.points[0] = point
	

func adjust_color(state):
	line.default_color = undefined_color if state.is_undefined() else \
		(on_color if state.is_true() else off_color)

func get_start_point():
	return line.points[0]

func set_end_point(point : Vector2):
	line.points[1] = point
	outline.points[1] = point

func set_point_by_index(point, idx):
	line.points[idx] = point
	outline.points[idx] = point

func get_end_point():
	return line.points[1]

func _exit_tree():
	if connected_output == null:
		return
	connected_output.remove_cable(self)
	connected_input.connected_cable = null
	connected_input.set_state(TriState.State.UNDEFINED)

func set_z_index(new_index):
	line.z_index = new_index
	outline.z_index = new_index
	print(new_index)
	connected_input.set_z_index(new_index + 1, -new_index - 1)
	connected_output.set_z_index(new_index + 1, -new_index - 1)
