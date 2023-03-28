extends PropertyInterface


@onready var text_edit = $LineEdit


func _ready():
	text_edit.connect("text_submitted", Callable(self, "change_text"))


func set_prop_value(new_text : String) -> void:
	text_edit.text = new_text


func change_text(new_text):
	emit_signal("value_changed", new_text)
