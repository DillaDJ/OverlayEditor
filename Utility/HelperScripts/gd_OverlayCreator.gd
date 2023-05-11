extends Button


@export var overlay_scn : PackedScene

var editor : Editor


func _ready() -> void:
	editor = sngl_Utility.get_scene_root()
	connect("button_down", Callable(self, "create_overlay"))


func create_overlay() -> void:
	var new_overlay = overlay_scn.instantiate()
	editor.register_overlay(new_overlay, editor.overlay_container, false)
