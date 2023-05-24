class_name SaveToggler
extends Button


@onready var save_menu = $SaveBG


func _ready():
	var editor = sngl_Utility.get_scene_root()
	
	$SaveBG/ButtonLayout/NewScene.connect("button_down", Callable(editor, "new_scene"))
	$SaveBG/ButtonLayout/NewScene.connect("button_down", Callable(self, "toggle_save_menu"))
	
	$SaveBG/ButtonLayout/Save.connect("button_down", Callable(editor, "prompt_save").bind(0))
	$SaveBG/ButtonLayout/SaveAs.connect("button_down", Callable(editor, "prompt_save").bind(1))
	$SaveBG/ButtonLayout/SaveScene.connect("button_down", Callable(editor, "prompt_save").bind(2))
	
	$SaveBG/ButtonLayout/LoadScene.connect("button_down", Callable(editor, "prompt_load").bind(0))
	$SaveBG/ButtonLayout/LoadOverlay.connect("button_down", Callable(editor, "prompt_load").bind(1))
	
	connect("toggled", Callable(self, "toggle_save_menu"))


func _input(event):
	if save_menu.is_visible_in_tree() and event is InputEventMouseButton:
		if !get_global_rect().has_point(event.position) and !save_menu.get_global_rect().has_point(event.position):
			set_pressed(false)
			save_menu.hide()


func toggle_save_menu(is_showing : bool):
	if is_showing:
		save_menu.show()
	else:
		save_menu.hide()
