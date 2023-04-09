extends PropertyInterface


@onready var color_picker = $ColorPickerButton


func _ready():
	color_picker.connect("color_changed", Callable(self, "set_color"))


func set_prop_value(new_color):
	color_picker.color = new_color


func set_color(new_color):
	emit_signal("value_changed", new_color)

