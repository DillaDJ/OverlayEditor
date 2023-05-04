class_name EventItemInterface
extends PanelContainer


@onready var time_trigger_scn : PackedScene = preload("res://Events/Triggers/scn_TimeTrigger.tscn")
@onready var twitch_chat_trigger_scn : PackedScene = preload("res://Events/Triggers/scn_TwitchChatTrigger.tscn")
@onready var property_set_trigger_scn : PackedScene = preload("res://Events/Triggers/scn_PropertySetTrigger.tscn")

@onready var print_action_scn = preload("res://Events/Actions/scn_PrintAction.tscn")
@onready var property_action_scn = preload("res://Events/Actions/scn_PropertyAction.tscn")
@onready var wait_action_scn = preload("res://Events/Actions/scn_WaitAction.tscn")

@onready var trigger_container 	: Control = $HorizontalLayout/VerticalLayout/TriggerBG/TriggerContainer
@onready var action_container 	: Control = $HorizontalLayout/VerticalLayout/ActionContainer

@onready var preview : Control = $HorizontalLayout/VerticalLayout/ActionContainer/Preview
@onready var action_fold_button = $HorizontalLayout/VerticalLayout/TriggerBG/TriggerContainer/FoldActions


func _ready() -> void:
	action_fold_button.connect("button_down", Callable(self, "toggle_action_visibility"))


# Triggers
func set_trigger_interface(trigger : Trigger) -> void:
	var interface
	
	match trigger.type:
		Trigger.Type.TIMED:
			interface = time_trigger_scn.instantiate()
			trigger_container.add_child(interface)
			setup_timed_trigger(interface, trigger)
		
		Trigger.Type.TWITCH_CHAT:
			interface = twitch_chat_trigger_scn.instantiate()
			trigger_container.add_child(interface)
			setup_twitch_chat_trigger(interface, trigger)
			
		Trigger.Type.PROPERTY:
			interface = property_set_trigger_scn.instantiate()
			trigger_container.add_child(interface)
			setup_property_trigger(interface, trigger)
	
	trigger_container.move_child(interface, 0)


func setup_timed_trigger(trigger_interface : Control, trigger : Trigger) -> void:
	var spinbox : SpinBox = trigger_interface.get_node("SpinBox")
		
	spinbox.value = trigger.trigger_time
	spinbox.connect("value_changed", Callable(trigger, "edit_time"))


func setup_twitch_chat_trigger(_trigger_interface : Control, _trigger : Trigger) -> void:
	return


func setup_property_trigger(trigger_interface : Control, trigger : Trigger):
	var prop_select 	: PropertySelectButton = trigger_interface.get_node("FieldLayout/PropertySelectButton")
	var field_matcher 	: FieldMatcher = trigger_interface.get_node("FieldLayout/FieldMatcher")
	
	# Set fields
	trigger_interface.mode = trigger.mode
	trigger_interface.toggle_equal(trigger.equal)
	
	# Trigger property
	if trigger.property:
		prop_select.text = trigger.property.get_display_name()
		
		if trigger.value_container.current_data_type == TYPE_OBJECT:
			var property : Property = trigger.value_container.get_property()
			field_matcher.fill_property(property)
		
		elif trigger.value_container.current_data_type != TYPE_NIL:
			field_matcher.match_property(trigger.property)
			field_matcher.fill_field(trigger.property, trigger.value_container.get_value())
	
	trigger.connect("property_nulled", Callable(field_matcher, "reset_property"))
	
	prop_select.connect("property_linked", Callable(trigger, "set_property"))
	prop_select.connect("property_linked", Callable(field_matcher, "match_property"))
	prop_select.connect("property_linked", Callable(trigger_interface, "disable_disallowed_modes"))
	
	field_matcher.connect("field_changed", Callable(trigger, "set_value"))
	field_matcher.connect("property_field_toggled", Callable(trigger, "toggle_property"))


# Actions
func add_action(event_editor : EventEditor, action : Action) -> void:
	var interface
	
	# Instantiate, add to scene then setup as _ready and @onready needs to
	# Run before setup and _ready only runs when a node is added to the scene 
	match action.type:
		Action.Type.PRINT:
			interface = print_action_scn.instantiate()
			action_container.add_child(interface)
			setup_print_action_interface(interface, action)
		Action.Type.PROPERTY:
			interface = property_action_scn.instantiate()
			action_container.add_child(interface)
			setup_property_action_interface(event_editor, interface, action)
		Action.Type.WAIT:
			interface = wait_action_scn.instantiate()
			action_container.add_child(interface)
			setup_wait_action_interface(interface, action)
	
	var burger_button : Button = interface.get_node("HorizontalLayout/BurgerButton")
	burger_button.connect("button_down", Callable(event_editor, "select_interface").bind(interface))
	
	if !action_container.is_visible_in_tree():
		toggle_action_visibility()
	preview.hide()


func setup_print_action_interface(action_interface : Control, action : PrintAction) -> void:
	var prop_select : Button = action_interface.get_node("HorizontalLayout/PropertySelectButton") 
			
	if action.property:
		prop_select.text = action.property.get_display_name()
	
	prop_select.connect("property_linked", Callable(action, "set_property"))


func setup_property_action_interface(event_editor : EventEditor, action_interface : Control, action : PropertyAction) -> void:
	var prop_select 	: Button = action_interface.get_node("HorizontalLayout/VerticalLayout/HorizontalLayout/PropertySelector")
	var field_matcher 	: FieldMatcher = action_interface.get_node("HorizontalLayout/VerticalLayout/HorizontalLayout/FieldMatcher")
	var anim_time 		: SpinBox = action_interface.get_node("HorizontalLayout/VerticalLayout/Options/SpinBox")
	var anim_type 		: OptionButton = action_interface.get_node("HorizontalLayout/VerticalLayout/Options/OptionButton")
	
	# Set fields
	action_interface.set_mode(action.add_mode)
	action_interface.toggle_animating(action.animating)
	anim_time.value = action.property_animator.length
	anim_type.select(action.property_animator.type)
	
	if action.property:
		prop_select.text = action.property.get_display_name()
		field_matcher.match_property(action.property)
		
		if action.value_container.current_data_type == TYPE_OBJECT:
			field_matcher.property_selector.text = action.value_container.get_property().get_display_name()
			field_matcher.matched_property = action.value_container.get_property()
			field_matcher.toggle_property()
		else:
			field_matcher.fill_field(action.property, action.value_container.get_value())
	
	# Connect property signals
	prop_select.connect("button_down", Callable(event_editor, "select_interface").bind(action_interface))
	prop_select.connect("property_linked", Callable(action_interface, "disable_disallowed_modes"))
	prop_select.connect("property_linked", Callable(action, "set_property"))
	
	action.connect("value_nulled", Callable(field_matcher, "reset_property"))
	field_matcher.connect("field_changed", Callable(action, "set_value"))
	
	anim_time.connect("value_changed", Callable(action.property_animator, "set_anim_length"))
	anim_type.connect("item_selected", Callable(action.property_animator, "set_anim_type"))


func setup_wait_action_interface(action_interface : Control, action : WaitAction):
	var spinbox : SpinBox = action_interface.get_node("HorizontalLayout/SpinBox") 
	spinbox.connect("value_changed", Callable(action, "set_wait_time"))


func remove_action_at(action_idx : int) -> void:
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
