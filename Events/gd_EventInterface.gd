class_name EventInterface
extends PanelContainer


@onready var time_trigger_scn = preload("res://Events/Triggers/scn_TimeTrigger.tscn")
@onready var twitch_chat_trigger_scn = preload("res://Events/Triggers/scn_TwitchChatTrigger.tscn")
@onready var property_set_trigger_scn = preload("res://Events/Triggers/scn_PropertySetTrigger.tscn")

@onready var print_action_scn = preload("res://Events/Actions/scn_PrintAction.tscn")
@onready var property_action_scn = preload("res://Events/Actions/scn_PropertyAction.tscn")

@onready var event_menu 		: EventMenu = sngl_Utility.get_scene_root().get_node("%Events")
@onready var trigger_container 	: Control = $HorizontalLayout/VerticalLayout/TriggerBG/TriggerContainer
@onready var action_container 	: Control = $HorizontalLayout/VerticalLayout/ActionContainer

@onready var preview : Control = $HorizontalLayout/VerticalLayout/ActionContainer/Preview
@onready var action_fold_button = $HorizontalLayout/VerticalLayout/TriggerBG/TriggerContainer/FoldActions


func _ready():
	action_fold_button.connect("button_down", Callable(self, "toggle_action_visibility"))


func add_trigger_interface(trigger : Trigger):
	var interface : Control
	
	match trigger.type:
		Trigger.Type.TIMED:
			interface = time_trigger_scn.instantiate()
			trigger_container.add_child(interface)
			trigger_container.move_child(interface, 0)
			
			var spinbox : SpinBox = interface.get_node("SpinBox")
			spinbox.value = trigger.trigger_time
			spinbox.connect("value_changed", Callable(trigger, "edit_time"))
		
		Trigger.Type.TWITCH_CHAT:
			interface = twitch_chat_trigger_scn.instantiate()
			trigger_container.add_child(interface)
			trigger_container.move_child(interface, 0)
			
		Trigger.Type.PROPERTY_SET:
			interface = property_set_trigger_scn.instantiate()
			trigger_container.add_child(interface)
			trigger_container.move_child(interface, 0)
			
			var checkbox	 	: CheckBox = interface.get_node("CheckBox")
			var prop_select 	: PropertySelectButton = interface.get_node("Description/PropertySelectButton")
			var field_matcher 	: FieldMatcher = interface.get_node("Description/FieldMatcher")
			
			checkbox.set_pressed(trigger.specific_value)
			
			if typeof(trigger.value) == TYPE_OBJECT:
				field_matcher.property_selector.text = trigger.value.prop_name.to_lower()
				field_matcher.matched_property = trigger.value
				field_matcher.toggle_property()
			elif trigger.property:
				prop_select.text = trigger.property.prop_name.to_lower()
				field_matcher.match_property(trigger.property)
				
				if trigger.value:
					field_matcher.fill_field(trigger.property, trigger.value)
			
			checkbox.connect("button_down", Callable(trigger, "toggle_specific_value"))
			prop_select.connect("button_down", Callable(event_menu, "select_interface").bind(self))
			prop_select.connect("property_linked", Callable(trigger, "change_property"))
			prop_select.connect("property_linked", Callable(field_matcher, "match_property"))
			field_matcher.connect("field_changed", Callable(trigger, "change_value"))


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


func toggle_action_visibility():
	if action_container.is_visible_in_tree():
		action_container.hide()
		action_fold_button.icon = sngl_Utility.caret_off
	else:
		action_container.show()
		action_fold_button.icon = sngl_Utility.caret_on
