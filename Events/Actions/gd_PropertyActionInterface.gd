extends PanelContainer


@onready var container : Control = $HorizontalLayout/VerticalLayout/HorizontalLayout
@onready var set_add_label : Control = $HorizontalLayout/VerticalLayout/HorizontalLayout/SetAddLabel
@onready var sub_label : Control = $HorizontalLayout/VerticalLayout/HorizontalLayout/SubtractLabel

@onready var property_selector : Control = $HorizontalLayout/VerticalLayout/HorizontalLayout/PropertySelector
@onready var options : OptionButton = $HorizontalLayout/VerticalLayout/HorizontalLayout/Mode


func _ready():
	var field_matcher = $HorizontalLayout/VerticalLayout/HorizontalLayout/FieldMatcher
	
	property_selector.connect("property_linked", Callable(field_matcher, "match_property"))
	options.connect("item_selected", Callable(self, "set_mode"))


func disable_disallowed_modes(property : Property):
	var all_allowed_modes = [TYPE_INT, TYPE_FLOAT, TYPE_VECTOR2, TYPE_VECTOR4, TYPE_COLOR]
	var add_allowed_modes = [TYPE_STRING, TYPE_STRING_NAME]
	
	if property.type in all_allowed_modes:
		options.set_item_disabled(1, false)
		options.set_item_disabled(2, false)
	
	elif property.type in add_allowed_modes:
		if options.selected == 2:
			options.select(0)
			options.item_selected.emit(0)
		options.set_item_disabled(1, false)
		options.set_item_disabled(2, true)
	
	else:
		if options.selected == 1 or options.selected == 2:
			options.select(0)
			options.item_selected.emit(0)
		options.set_item_disabled(1, true)
		options.set_item_disabled(2, true)


func set_mode(mode : PropertyAction.Mode):
	set_add_label.hide()
	sub_label.hide()
	
	match mode:
		PropertyAction.Mode.SET:
			set_add_label.show()
			container.move_child(property_selector, 1)
			container.move_child(set_add_label, 2)
			
		PropertyAction.Mode.ADD:
			set_add_label.show()
			container.move_child(set_add_label, 5)
			property_selector.move_to_front()
		
		PropertyAction.Mode.SUBTRACT:
			sub_label.show()
			property_selector.move_to_front()

