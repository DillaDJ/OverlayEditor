extends Button


@onready var settings : Control = %Settings 


func _ready():
	connect("button_down", Callable(settings, "show"))
