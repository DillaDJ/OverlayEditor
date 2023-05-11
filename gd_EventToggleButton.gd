extends Button


@onready var editor : Editor = sngl_Utility.get_scene_root()
@onready var play_icon : Texture2D = preload("res://Icons/play.png")
@onready var stop_icon : Texture2D = preload("res://Icons/stop.png")


func _ready() -> void:
	connect("toggled", Callable(self, "toggle_events")) 


func toggle_events(events_enabled) -> void:
	editor.events_enabled = events_enabled
	editor.events_toggled.emit(events_enabled)
	
	if events_enabled:
		icon = stop_icon
	else:
		icon = play_icon
