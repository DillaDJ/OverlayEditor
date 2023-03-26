extends Button


@export var overlay_scn : PackedScene


func _ready():
	connect("button_down", Callable(sngl_Utility.get_scene_root(), "create_overlay").bind(overlay_scn))
