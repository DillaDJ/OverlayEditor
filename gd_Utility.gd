class_name Utility
extends Node


enum OverlayTypes { PANEL, TEXT }


func _ready():
	var window : Window = get_tree().get_root()
	window.set_flag(Window.FLAG_TRANSPARENT, true)


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
