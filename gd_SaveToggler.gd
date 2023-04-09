extends Button


@onready var save_menu = $SaveBG


func _ready():
	var editor = sngl_Utility.get_scene_root()
	
	$SaveBG/ButtonLayout/NewScene.connect("button_down", Callable(editor, "placeholder"))
	$SaveBG/ButtonLayout/SaveScene.connect("button_down", Callable(editor, "placeholder"))
	$SaveBG/ButtonLayout/SaveNode.connect("button_down", Callable(editor, "start_save"))
	$SaveBG/ButtonLayout/LoadScene.connect("button_down", Callable(editor, "placeholder"))
	$SaveBG/ButtonLayout/LoadNode.connect("button_down", Callable(editor, "start_load"))
	
	connect("button_down", Callable(self, "toggle_save_menu"))


func toggle_save_menu():
	if save_menu.is_visible_in_tree():
		save_menu.hide()
	else:
		save_menu.show()
