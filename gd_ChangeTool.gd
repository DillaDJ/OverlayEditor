extends Button

@export var tool_to_select : Editor.EditingTools



func _ready():
	var editor = sngl_Utility.get_scene_root()
	connect("button_down", Callable(editor, "select_tool").bind(tool_to_select))


