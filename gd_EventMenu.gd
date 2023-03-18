extends Panel

@onready var event_interface_scn : PackedScene = preload("res://Overlays/Events/scn_EventInterface.tscn")
@onready var event_container 	: Control = $VBoxContainer/ScrollContainer/EventContainer
@onready var new_event_button 	: Button = $VBoxContainer/Toolbar/HBoxContainer/NewGlobalEvent
@onready var new_action_button 	: Button = $VBoxContainer/Toolbar/HBoxContainer/NewGlobalAction
@onready var delete_button 		: Button = $VBoxContainer/Toolbar/HBoxContainer/Delete

@export var unselected_event_theme 	: StyleBoxFlat
@export var selected_event_theme 	: StyleBoxFlat

@export var unselected_action_theme : StyleBoxFlat
@export var selected_action_theme 	: StyleBoxFlat

var global_events : Array[Event] = []
var selected_overlay : Overlay

var selected_interface_idx 	: int = -1
var selected_action_idx 	: int = -1

signal message_sent()


func _ready() -> void:
	# Event Trigger
	new_event_button.get_popup().connect("id_pressed", Callable(self, "create_event"))
	
	# Event Actions
	new_action_button.get_popup().connect("id_pressed", Callable(self, "create_action"))
	
	delete_button.connect("button_down", Callable(self, "delete_selected"))
	
	%MoveTool.connect("overlay_selected", Callable(self, "populate_events"))
	%MoveTool.connect("overlay_deselected", Callable(self, "populate_global_events"))


func create_event(trigger_type : int) -> void:
	var event_interface : EventInterface = create_event_interface()
	
	var trigger
	match trigger_type as Trigger.Type:
		Trigger.Type.TIMED:
			trigger = TimeTrigger.new()
			
		Trigger.Type.TWITCH_CHAT:
			trigger = TwitchChatTrigger.new()
	
	var event := Event.new(trigger)
	
	selected_overlay.attached_events.append(event)
	event_interface.add_trigger_interface(trigger)


func create_event_interface() -> EventInterface:
	var event_interface : EventInterface = event_interface_scn.instantiate()
	event_interface.get_node("HorizontalLayout/BurgerButton").connect("button_down", Callable(self, "select_interface").bind(event_interface))
	event_container.add_child(event_interface)
	
	return event_interface


func create_action(action_type : Action.Type) -> void:
	var selected_interface : EventInterface = event_container.get_child(selected_interface_idx)
	var selected_event : Event = selected_overlay.attached_events[selected_interface_idx]
	var action : Action
	
	match action_type:
		Action.Type.PRINT:
			action = PrintAction.new()
	
	create_action_interface(selected_interface, action)
	
	selected_event.add_action(action)


func create_action_interface(selected_interface : EventInterface, action : Action) -> void:
	var action_interface : Control = selected_interface.add_action_interface(action)
	var burger_button : Button = action_interface.get_node("HorizontalLayout/BurgerButton")
	
	burger_button.connect("button_down", Callable(self, "select_interface").bind(action_interface))
	
	match action.type:
		Action.Type.PRINT:
			var line_edit : LineEdit = action_interface.get_node("HorizontalLayout/LineEdit") 
			line_edit.text = action.message
			
			line_edit.connect("text_changed", Callable(action, "change_message"))


func select_interface(interface : Control) -> void:
	var selected_interface : Control
	
	# Destyling
	if selected_action_idx != -1:
		selected_interface = event_container.get_child(selected_interface_idx).action_container.get_child(selected_action_idx)
		selected_interface.remove_theme_stylebox_override("panel")
		selected_interface.add_theme_stylebox_override("panel", unselected_action_theme)
	
	if selected_interface_idx != -1:
		selected_interface = event_container.get_child(selected_interface_idx)
		selected_interface.remove_theme_stylebox_override("panel")
		selected_interface.add_theme_stylebox_override("panel", unselected_event_theme)
	
	# Getting
	if interface.get_parent() != event_container:
		selected_action_idx = interface.get_index()
		
		while interface.get_parent() != event_container:
			interface = interface.get_parent()
	else:
		selected_action_idx = -1
	
	selected_interface_idx = interface.get_index()
	selected_interface = event_container.get_child(selected_interface_idx)
	
	# Styling
	if selected_action_idx != -1:
		selected_interface = event_container.get_child(selected_interface_idx).action_container.get_child(selected_action_idx)
		selected_interface.remove_theme_stylebox_override("panel")
		selected_interface.add_theme_stylebox_override("panel", selected_action_theme)
	else:
		selected_interface.remove_theme_stylebox_override("panel")
		selected_interface.add_theme_stylebox_override("panel", selected_event_theme)
	
	new_action_button.disabled = false
	delete_button.disabled = false


func delete_selected():
	if selected_interface_idx != -1:
		if selected_action_idx != -1:
			var interface : EventInterface = event_container.get_child(selected_interface_idx)
			var event : Event = selected_overlay.attached_events[selected_interface_idx]
			
			interface.remove_action_interface_at(selected_action_idx)
			event.remove_action_at(selected_action_idx)
		else:
			var interface = event_container.get_child(selected_interface_idx)
			selected_overlay.attached_events.remove_at(selected_interface_idx)
			selected_interface_idx = -1
			interface.queue_free()
		selected_action_idx = -1
	
	new_action_button.disabled = true
	delete_button.disabled = true


func populate_events(overlay) -> void:
	new_event_button.disabled = false
	selected_overlay = overlay
	clear_event_panel()
	
	for event in selected_overlay.attached_events:
		var event_interface = create_event_interface()
		
		event_interface.add_trigger_interface(event.trigger)
		
		for action in event.actions:
			create_action_interface(event_interface, action)


func populate_global_events() -> void:
	new_event_button.disabled = true
	selected_overlay = null
	clear_event_panel()


func clear_event_panel():
	for child in event_container.get_children():
		child.queue_free()
	
	selected_interface_idx = -1
	selected_action_idx = -1
