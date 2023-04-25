extends Button


@onready var editor : Editor = sngl_Utility.get_scene_root()

@export var play_icon : Texture2D
@export var stop_icon : Texture2D


func _ready():
	connect("button_down", Callable(self, "toggle_events")) 


func toggle_events():
	editor.toggle_events()
	
	if icon == play_icon:
		icon = stop_icon
	else:
		icon = play_icon
