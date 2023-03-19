extends PanelContainer


@onready var container : Control = $HorizontalLayout
@onready var set_add_label : Control = $HorizontalLayout/SetAddLabel
@onready var sub_label : Control = $HorizontalLayout/SubtractLabel

@onready var property_selector : Control = $HorizontalLayout/PropertySelector


func _ready():
	var field_matcher = $HorizontalLayout/FieldMatcher
	
	property_selector.connect("property_linked", Callable(field_matcher, "match_property"))
	$HorizontalLayout/Mode.connect("item_selected", Callable(self, "set_mode"))


func set_mode(mode : PropertyAction.Mode):
	set_add_label.hide()
	sub_label.hide()
	
	match mode:
		PropertyAction.Mode.SET:
			set_add_label.show()
			container.move_child(property_selector, 2)
			container.move_child(set_add_label, 3)
			
		PropertyAction.Mode.ADD:
			set_add_label.show()
			container.move_child(set_add_label, 5)
			property_selector.move_to_front()
		
		PropertyAction.Mode.SUBTRACT:
			sub_label.show()
			property_selector.move_to_front()

