extends PropertyInterface


@onready var options : OptionButton = $OptionButton


func _ready():
	options.connect("item_selected", Callable(self, "change_item"))


func set_prop_value(new_item : int) -> void:
	options.select(new_item)


func change_item(new_item : int) -> void:
	emit_signal("value_changed", new_item)


func add_option(option_name : String) -> void:
	options.add_item(option_name)
