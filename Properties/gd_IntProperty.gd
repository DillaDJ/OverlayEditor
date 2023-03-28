extends PropertyInterface


@onready var spin_box = $SpinBox


func _ready():
	spin_box.connect("value_changed", Callable(self, "change_int"))


func set_prop_value(new_int) -> void:
	spin_box.value = new_int


func change_int(new_int) -> void:
	emit_signal("value_changed", new_int)
