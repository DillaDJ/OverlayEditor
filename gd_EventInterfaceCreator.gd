class_name EventInterfaceCreator
extends VBoxContainer


@onready var event_interface_scn : PackedScene = preload("res://Events/scn_EventItemInterface.tscn")


func create_event_interface(event_editor : EventEditor, event : Event) -> EventItemInterface:
	var event_interface : EventItemInterface = event_interface_scn.instantiate()
	event_interface.set_trigger_interface(event.trigger)
	add_child(event_interface)
	
	var burger_button = event_interface.get_node("HorizontalLayout/BurgerButton")
	burger_button.connect("button_down", Callable(event_editor, "select_interface").bind(event_interface))
	
	return event_interface


func create_action_interface(event_editor : EventEditor, event_interface : EventItemInterface, action : Action) -> void:
	var action_interface : Control = event_interface.add_action_interface(action)
	
	match action.type:
		Action.Type.PRINT:
			setup_print_action_interface(action_interface, action)
		Action.Type.PROPERTY:
			setup_property_action_interface(event_editor, action_interface, action)
	
	action_interface.get_node("HorizontalLayout/BurgerButton").connect("button_down", Callable(self, "select_interface").bind(action_interface))


func setup_print_action_interface(action_interface : Control, action : PrintAction) -> void:
	var prop_select : Button = action_interface.get_node("HorizontalLayout/PropertySelectButton") 
			
	if action.property:
		prop_select.text = action.property.get_display_name()
	
	prop_select.connect("property_linked", Callable(action, "change_property"))


func setup_property_action_interface(event_editor : EventEditor, action_interface : Control, action : PropertyAction) -> void:
	var prop_select 	: Button = action_interface.get_node("HorizontalLayout/VerticalLayout/HorizontalLayout/PropertySelector")
	var mode_select 	: OptionButton = action_interface.get_node("HorizontalLayout/VerticalLayout/HorizontalLayout/Mode")
	var field_matcher 	: FieldMatcher = action_interface.get_node("HorizontalLayout/VerticalLayout/HorizontalLayout/FieldMatcher")
	var anim_time 		: SpinBox = action_interface.get_node("HorizontalLayout/VerticalLayout/Options/SpinBox")
	var anim_type 		: OptionButton = action_interface.get_node("HorizontalLayout/VerticalLayout/Options/OptionButton")
	
	# Set interface to property values
	action_interface.set_mode(action.mode)
	mode_select.select(action.mode)
	
	if action.property:
		prop_select.text = action.property.get_display_name()
		field_matcher.match_property(action.property)
		
		if typeof(action.value_container.get_value()) == TYPE_OBJECT:
			field_matcher.property_selector.text = action.value.get_display_name()
			field_matcher.matched_property = action.value
			field_matcher.toggle_property()
		else:
			field_matcher.fill_field(action.property, action.value_container.get_value())
	
	# Connect property signals
	prop_select.connect("button_down", Callable(event_editor, "select_interface").bind(action_interface, true))
	prop_select.connect("property_linked", Callable(action_interface, "disable_disallowed_modes"))
	prop_select.connect("property_linked", Callable(action, "change_property"))
	
	action.connect("value_nulled", Callable(field_matcher, "reset_property"))
	field_matcher.connect("field_changed", Callable(action, "change_value"))
	mode_select.connect("item_selected", Callable(action, "change_mode"))
	
	anim_time.connect("value_changed", Callable(action.property_animator, "set_anim_length"))
	anim_type.connect("item_selected", Callable(action.property_animator, "set_anim_type"))


func clear() -> void:
	for child in get_children():
		child.queue_free()
