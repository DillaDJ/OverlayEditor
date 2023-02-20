class_name Utility
extends Node


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
