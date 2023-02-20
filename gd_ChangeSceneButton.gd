extends Control


@export var scene_name : String


func _ready():
	connect("button_down", Callable(sngl_Utility, "change_scene").bind(scene_name))
