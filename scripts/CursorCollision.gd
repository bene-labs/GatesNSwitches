extends Node2D

var elements : Array = []

var hovered_element = null
var is_mouse_movement = false
var is_locked = false

var whitelist : Array

func _ready():
	pass

func add_to_whitelist(type):
	if whitelist.has(type):
		return
	whitelist.append(type)

func remove_from_whitelist(type):
	whitelist.erase(type)

func lock():
	is_locked = true
	
func unlock():
	is_locked = false

func get_global_z_index(element):
	var z_index = element.get_z_index()
	while element.z_as_relative && element.get_parent() is Node2D:
		element = element.get_parent()
		z_index += element.z_index
	return z_index

func compare_z_index(elem1, elem2) -> bool:
	var z_index1 = get_global_z_index(elem1)
	var z_index2 = get_global_z_index(elem2) 

	#print(elem1.name, ": ", z_index1, " | ", elem2.name, ": ", z_index2)

	return z_index1 > z_index2
		
func update_order():
	elements.sort_custom(self, "compare_z_index")

func register(element):
	elements.push_back(element)
	update_order()

func unregister(element):
	if hovered_element == element:
		hovered_element = null
	elements.erase(element)

func _input(event):
	if is_locked: 
		return
	var mous_pos = get_global_mouse_position()
	for element in elements:
		if whitelist.size() != 0:
			var test = element.name
			if not whitelist.has(test):
				continue
			
		if element.is_point_inside(mous_pos):
			if element == hovered_element:
				return
			if hovered_element != null:
				hovered_element._on_mouse_exited()
			element._on_mouse_entered()
			hovered_element = element
			return
	if hovered_element != null:
		hovered_element._on_mouse_exited()
		hovered_element = null


