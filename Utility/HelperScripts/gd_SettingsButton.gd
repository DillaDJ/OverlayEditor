extends Button


@onready var settings : Control = %Settings 


func _ready():
	connect("toggled", Callable(self, "toggle_settings"))


func toggle_settings(settings_showing : bool):
	if settings_showing:
		settings.show()
	else:
		settings.hide()
