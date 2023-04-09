extends PropertyInterface


@onready var check_box = $CheckBox


func _ready():
	check_box.connect("button_down", Callable(self, "toggle_bool"))


func set_prop_value(new_bool) -> void:
	check_box.set_pressed(new_bool)


func toggle_bool() -> void:
	emit_signal("value_changed", !check_box.is_pressed())
