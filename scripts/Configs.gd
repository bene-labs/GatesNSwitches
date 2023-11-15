extends Node

var simulation_speed : float = 0.1

func _input(event):
	if event.is_action("simulation_speed_up"):
		simulation_speed -= 0.005
	elif event.is_action("simulation_speed_down"):
		simulation_speed += 0.005
	else:
		return
	print(simulation_speed)
	simulation_speed = clamp(simulation_speed, 0.025, 1.0)
