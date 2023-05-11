extends Button

enum Type { NONE, PROP_TRIGGER, PROP_ACTION }

@onready var prop_trigger 	:= $Triggers/Property 
@onready var prop_action 	:= $Actions/Property 

var current_popup_button : MenuButton
var current_interface : Control
var current_event_or_action : Variant


func _ready():
	connect("button_down", Callable(self, "show_popup"))


func connect_signals(interface : Control, event_or_action : Variant):
	var type : Type = get_event_or_action_and_type(event_or_action)
	match type:
		Type.PROP_TRIGGER:
			var popup = prop_trigger.get_popup()
			popup.connect("id_pressed", Callable(event_or_action.trigger, "process_settings"))
		Type.PROP_ACTION:
			var popup = prop_action.get_popup()
			popup.connect("id_pressed", Callable(event_or_action, "process_settings"))
	
	if current_popup_button:
		current_popup_button.get_popup().connect("id_pressed", Callable(interface, "process_settings"))
	current_interface = interface
	current_event_or_action = event_or_action


func disconnect_signals():
	if current_event_or_action != null:
		var type : Type = get_event_or_action_and_type(current_event_or_action)
		match type:
			Type.PROP_TRIGGER:
				var popup = prop_trigger.get_popup()
				if popup.is_connected("id_pressed", Callable(current_event_or_action.trigger, "process_settings")):
					popup.disconnect("id_pressed", Callable(current_event_or_action.trigger, "process_settings"))
			
			Type.PROP_ACTION:
				var popup = prop_action.get_popup()
				if popup.is_connected("id_pressed", Callable(current_event_or_action, "process_settings")):
					popup.disconnect("id_pressed", Callable(current_event_or_action, "process_settings"))
		
		current_event_or_action = null
	
	if current_interface != null:
		if current_interface.settings_popup.is_connected("id_pressed", Callable(current_interface, "process_settings")):
			current_interface.settings_popup.disconnect("id_pressed", Callable(current_interface, "process_settings"))
		current_interface.settings_popup = null
		
		if current_popup_button and current_popup_button.get_popup().is_connected("id_pressed", Callable(current_interface, "process_settings")):
			current_popup_button.get_popup().disconnect("id_pressed", Callable(current_interface, "process_settings"))
		
		current_interface = null


func set_current_popup(interface : Control, event_or_action : Variant) -> void:
	if interface != current_interface:
		reset_popups()
	disconnect_signals()
	
	var type : Type = get_event_or_action_and_type(event_or_action)
	match type:
		Type.NONE:
			clear()
			return
		
		Type.PROP_TRIGGER:
			current_popup_button = prop_trigger
			interface = interface.trigger_container.get_child(0)
			
			# Set fields
			var popup = prop_trigger.get_popup()
			interface.settings_popup = popup
			
			popup.set_item_checked(event_or_action.trigger.mode, true)
			popup.set_item_checked(4, event_or_action.trigger.equal)
			interface.disable_disallowed_modes(event_or_action.trigger.property)
		
		Type.PROP_ACTION:
			current_popup_button = prop_action
			
			# Set fields
			var popup = prop_action.get_popup()
			interface.settings_popup = popup
			
			popup.set_item_checked(event_or_action.add_mode, true)
			popup.set_item_checked(3, event_or_action.animating)
			interface.disable_disallowed_modes(event_or_action.property)

	connect_signals(interface, event_or_action)


func show_popup() -> void:
	if current_popup_button == null:
		set_disabled(true)
		return
	
	current_popup_button.show_popup()


func reset_popups():
	var popup = prop_trigger.get_popup()
	for i in range(popup.item_count):
		popup.set_item_checked(i, false)
	
	popup = prop_action.get_popup()
	for i in range(popup.item_count):
		popup.set_item_checked(i, false)


func clear():
	current_popup_button = null
	current_interface = null
	current_event_or_action = null
	set_disabled(true)


func get_event_or_action_and_type(event_or_action : Variant) -> Type:
	if event_or_action is Event:
		var event : Event = event_or_action
		match event.trigger.type:
			Trigger.Type.PROPERTY:
				return Type.PROP_TRIGGER
	
	elif event_or_action is Action:
		var action : Action = event_or_action
		match action.type:
			Action.Type.PROPERTY:
				return Type.PROP_ACTION
	
	return Type.NONE
