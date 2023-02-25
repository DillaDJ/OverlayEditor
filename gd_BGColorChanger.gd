extends Button


@onready var picker : ColorPicker = $ColorPickerBG/ColorPicker


func _ready():
	picker.connect("color_changed", Callable(self, "change_bg_color"))
	#connect("focus_exited", Callable($ColorPickerBG, "hide"))
	connect("button_down", Callable(self, "toggle_picker"))


func toggle_picker():
	var picker_bg : Control = $ColorPickerBG
	
	if picker_bg.is_visible_in_tree():
		picker_bg.hide()
	else:
		picker_bg.show()


func change_bg_color(new_color):
	%BGColorRect.color = new_color
	
