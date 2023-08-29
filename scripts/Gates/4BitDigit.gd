extends Gate

func _on_input_changed():
	._on_input_changed()

	var step
	var value = 0
	
	for i in range(inputs.size()):
		step = pow(2, i)
		value += step if inputs[i].state.is_true() else 0
		
	$Sprite/ColorRect/Digit.frame = value
