extends HBoxContainer


@onready var toggle_show = get_parent().get_node("ToggleShow")
@onready var parent = get_parent()

var resizing := false


func _ready():
	$Resize.connect("button_down", Callable(self, "resize").bind(true))
	$Resize.connect("button_up", Callable(self, "resize").bind(false))


func _process(_delta):
	if resizing:
		var mouse_pos = get_viewport().get_mouse_position().x - 4
		var screen_width = get_viewport().size.x
		if mouse_pos > screen_width - 8:
			return
		
		var new_size = screen_width - mouse_pos - 4
		parent.global_position.x = screen_width - new_size
		size.x = new_size
		
		toggle_show.global_position.x = screen_width - new_size - 36
		get_parent().move_width = new_size
		get_parent().adjust_anim_clips()


func resize(start):
	resizing = start
