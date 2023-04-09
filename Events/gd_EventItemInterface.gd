class_name EventItemInterface
extends PanelContainer


@onready var time_trigger_scn = preload("res://Events/Triggers/scn_TimeTrigger.tscn")
@onready var twitch_chat_trigger_scn = preload("res://Events/Triggers/scn_TwitchChatTrigger.tscn")
@onready var property_set_trigger_scn = preload("res://Events/Triggers/scn_PropertySetTrigger.tscn")

@onready var print_action_scn = preload("res://Events/Actions/scn_PrintAction.tscn")
@onready var property_action_scn = preload("res://Events/Actions/scn_PropertyAction.tscn")

@onready var trigger_container 	: Control = $HorizontalLayout/VerticalLayout/TriggerBG/TriggerContainer
@onready var action_container 	: Control = $HorizontalLayout/VerticalLayout/ActionContainer

@onready var preview : Control = $HorizontalLayout/VerticalLayout/ActionContainer/Preview
@onready var action_fold_button = $HorizontalLayout/VerticalLayout/TriggerBG/TriggerContainer/FoldActions


func _ready() -> void:
	action_fold_button.connect("button_down", Callable(self, "toggle_action_visibility"))


func set_trigger_interface(trigger : Trigger) -> void:
	var event_menu : EventEditor = sngl_Utility.get_scene_root().get_node("%Events")
	var interface
	
	match trigger.type:
		Trigger.Type.TIMED:
			interface = setup_timed_trigger(trigger)
		
		Trigger.Type.TWITCH_CHAT:
			interface = setup_twitch_chat_trigger()
			
		Trigger.Type.PROPERTY:
			interface = setup_property_trigger(trigger)
		
	trigger_container.add_child(interface)
	trigger_container.move_child(interface, 0)


func setup_timed_trigger(trigger : Trigger) -> Control:
	var interface : Control = time_trigger_scn.instantiate()
	var spinbox : SpinBox = interface.get_node("SpinBox")
	
	spinbox.value = trigger.trigger_time
	spinbox.connect("value_changed", Callable(trigger, "edit_time"))
	
	return interface


func setup_twitch_chat_trigger() -> Control:
	var interface = twitch_chat_trigger_scn.instantiate()
	return interface


func setup_property_trigger(trigger : Trigger) -> Control:
	var interface 		: Control = property_set_trigger_scn.instantiate()
	var checkbox	 	: CheckBox = interface.get_node("CheckBox")
	var options	 		: OptionButton = interface.get_node("FieldLayout/OptionButton")
	var prop_select 	: PropertySelectButton = interface.get_node("FieldLayout/PropertySelectButton")
	var field_matcher 	: FieldMatcher = interface.get_node("FieldLayout/FieldMatcher")
	
	# Set fields
	if typeof(trigger.value_container.get_value()) == TYPE_OBJECT:
		field_matcher.property_selector.text = trigger.value_container.get_value().prop_name.to_lower()
		field_matcher.matched_property = trigger.value_container.get_value()
		field_matcher.toggle_property()
	elif trigger.property:
		prop_select.text = trigger.property.prop_name.to_lower()
		field_matcher.match_property(trigger.property)
		
		if trigger.value_container.get_value():
			field_matcher.fill_field(trigger.property, trigger.value_container.get_value())
	checkbox.set_pressed(trigger.equal)
	
	# Connections
	trigger.connect("property_nulled", Callable(field_matcher, "reset_property"))
	checkbox.connect("button_down", Callable(trigger, "toggle_equal"))
	options.connect("item_selected", Callable(trigger, "set_mode"))
	
	prop_select.connect("property_linked", Callable(trigger, "change_property"))
	prop_select.connect("property_linked", Callable(field_matcher, "match_property"))
	prop_select.connect("property_linked", Callable(interface, "disable_disallowed_modes"))
	
	field_matcher.connect("field_changed", Callable(trigger, "change_value"))
	
	return interface


func add_action_interface(action) -> Control:
	var interface
	
	match action.type:
		Action.Type.PRINT:
			interface = print_action_scn.instantiate()
		
		Action.Type.PROPERTY:
			interface = property_action_scn.instantiate()
	
	action_container.add_child(interface)
	
	if !action_container.is_visible_in_tree():
		toggle_action_visibility()
	preview.hide()
	
	return interface


func remove_action_interface_at(action_idx) -> void:
	if action_container.get_child_count() == 2:
		preview.show()
	
	action_container.get_child(action_idx).queue_free()


func toggle_action_visibility() -> void:
	if action_container.is_visible_in_tree():
		action_container.hide()
		action_fold_button.icon = sngl_Utility.caret_off
	else:
		action_container.show()
		action_fold_button.icon = sngl_Utility.caret_on
