class_name Utility
extends Node


enum OverlayTypes { PANEL, TEXT }

@onready var caret_on 	: Texture2D = preload("res://Icons/caret-on.png")
@onready var caret_off 	: Texture2D = preload("res://Icons/caret-off.png")

var sync_timer : Timer


func _ready():
	var window : Window = get_tree().get_root()
	window.set_flag(Window.FLAG_TRANSPARENT, true)
	
	sync_timer = Timer.new()
	sync_timer.wait_time = 1.0
	sync_timer.one_shot = true
	add_child(sync_timer)


func change_scene(scene):
	var new_scene : String
	
	match scene:
		"edit":
			new_scene = "res://scn_EditMode.tscn"
		
		"overlay":
			new_scene = "res://scn_OverlayMode.tscn"
		
		_:
			return
	
	get_tree().change_scene_to_file(new_scene)


func get_scene_root():
	return get_tree().get_current_scene()


func gcd(a, b):
	var temp
	
	while b != 0:
		temp = a
		a = b
		b = temp % b
	
	return a


# Formatted like: [parent, [child, [child of child], child], nochildren, parent, [child], ...]
func get_nested_children(node : Node) -> Array:
	var children : Array = []
	
	for child in node.get_children():
		children.append(child)
		
		var deep_children = get_nested_children(child)
		if deep_children.size() > 0:
			children.append(deep_children)
	
	return children


# Formatted in the same way as the above function but made into a 1D array
func get_nested_children_flat(node : Node) -> Array[Node]:
	var children : Array[Node] = []
	
	for child in node.get_children():
		children.append(child)
		
		var deep_children = get_nested_children_flat(child)
		for deep_child in deep_children:
			children.append(deep_child)
	
	return children
