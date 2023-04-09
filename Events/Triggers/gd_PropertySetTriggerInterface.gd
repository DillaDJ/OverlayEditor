extends VBoxContainer


@onready var checkbox : CheckBox = $CheckBox
@onready var options : OptionButton = $FieldLayout/OptionButton
@onready var layout_container := $FieldLayout

@onready var and_label : Label = $FieldLayout/AndLabel
@onready var or_label : Label = $FieldLayout/OrLabel

@onready var field_matcher : FieldMatcher = $FieldLayout/FieldMatcher


func _ready():
	checkbox.connect("toggled", Callable(self, "toggle_equals"))
	options.connect("item_selected", Callable(self, "set_field_layout"))


func toggle_equals(pressed : bool) -> void:
	if pressed:
		checkbox.reparent(layout_container)
		layout_container.move_child(checkbox, 6)
	else:
		checkbox.reparent(self)
		
	
	set_field_layout(options.selected)


func set_field_layout(idx : int) -> void:
	if checkbox.is_pressed():
		if idx == 0:
			or_label.hide()
			and_label.show()
			field_matcher.show()
		else:
			and_label.hide()
			or_label.show()
			field_matcher.show()
			
	else:
		if idx == 0:
			or_label.hide()
			and_label.hide()
			field_matcher.hide()
		else:
			and_label.hide()
			or_label.hide()
			field_matcher.show()


func disable_disallowed_modes(property : Property):
	var allowed_modes = [TYPE_INT, TYPE_FLOAT]
	
	if property.type in allowed_modes:
		options.set_item_disabled(1, false)
		options.set_item_disabled(2, false)
		
	else:
		if options.selected == 1 or options.selected == 2:
			options.select(0)
			options.item_selected.emit(0)
		options.set_item_disabled(1, true)
		options.set_item_disabled(2, true)

