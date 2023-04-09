extends PropertyInterface


@onready var text_edit = $TextEdit


func _ready():
	text_edit.connect("text_changed", Callable(self, "change_text"))


func set_prop_value(new_text : String) -> void:
	text_edit.text = new_text


func change_text():
	emit_signal("value_changed", text_edit.text)
