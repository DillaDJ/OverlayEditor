class_name EventEditor
extends Panel

@onready var interface_creator 	: EventInterfaceCreator = $VerticalLayout/ScrollContainer/EventContainer
@onready var new_event_button 	: Button = $VerticalLayout/Toolbar/HBoxContainer/NewEvent
@onready var new_action_button 	: Button = $VerticalLayout/Toolbar/HBoxContainer/NewAction
@onready var delete_button 		: Button = $VerticalLayout/Toolbar/HBoxContainer/Delete

@export var unselected_event_theme 	: StyleBoxFlat
@export var selected_event_theme 	: StyleBoxFlat
@export var unselected_action_theme : StyleBoxFlat
@export var selected_action_theme 	: StyleBoxFlat

# For mapping interface to event/action
var selected_event_idx 	: int = -1
var selected_action_idx : int = -1

var selected_overlay : Overlay

signal event_created(event : Event)
signal event_deleted()
signal event_selected(event : Event)


func _ready() -> void:
	var editor = sngl_Utility.get_scene_root()
	
	editor.connect("overlay_selected", Callable(self, "populate"))
	editor.connect("overlay_deselected", Callable(self, "clear"))
	
	new_event_button.get_popup().connect("id_pressed", Callable(self, "create_event"))
	new_action_button.get_popup().connect("id_pressed", Callable(self, "create_action"))
	
	delete_button.connect("button_down", Callable(self, "delete_selected"))


func create_event(trigger_type : int) -> void:
	var event := Event.new()
	var trigger
	
	match trigger_type as Trigger.Type:
		Trigger.Type.TIMED:
			trigger = TimeTrigger.new()
			
		Trigger.Type.TWITCH_CHAT:
			trigger = TwitchChatTrigger.new()
			
		Trigger.Type.PROPERTY:
			trigger = PropertySetTrigger.new()
	
	event.attach_trigger(trigger)
	selected_overlay.attached_events.append(event)
	interface_creator.create_event_interface(self, event)
	event_created.emit(event)


func create_action(action_type : Action.Type) -> void:
	var selected_event_interface : EventItemInterface = get_selected_interface(true)
	var selected_event : Event = selected_overlay.attached_events[selected_event_idx]
	var action : Action
	
	match action_type:
		Action.Type.PRINT:
			action = PrintAction.new()
		
		Action.Type.PROPERTY:
			action = PropertyAction.new()
			action.value_container = VariantDataContainer.new()
			action.property_animator = PropertyAnimator.new()
	
	interface_creator.create_action_interface(self, selected_event_interface, action)
	selected_event.add_action(action)


func select_interface(interface : PanelContainer, ignore_action : bool = false) -> void:
	var new_event_idx : int
	var changed := false
	
	# Destyle
	style_interface(get_selected_interface(), unselected_action_theme if selected_action_idx != -1 else unselected_event_theme)
	
	# Select
	selected_action_idx = get_action_idx(interface, ignore_action)
	new_event_idx = get_event_idx(interface)
	
	if selected_event_idx != new_event_idx:
		selected_event_idx = new_event_idx
		event_selected.emit(selected_overlay.attached_events[selected_event_idx])
	
	# Style
	style_interface(get_selected_interface(), selected_action_theme if selected_action_idx != -1 else selected_event_theme)
	new_action_button.disabled = false
	delete_button.disabled = false


func delete_selected() -> void:
	if selected_event_idx != -1:
		if selected_action_idx != -1:
			interface_creator.get_child(selected_event_idx).remove_action_interface_at(selected_action_idx)
			selected_overlay.attached_events[selected_event_idx].remove_action_at(selected_action_idx)
		else:
			interface_creator.get_child(selected_event_idx).queue_free()
			selected_overlay.attached_events[selected_event_idx].delete()
			selected_overlay.attached_events.remove_at(selected_event_idx)
			selected_event_idx = -1
		selected_action_idx = -1
	
	new_action_button.disabled = true
	delete_button.disabled = true


func populate(overlay : Overlay) -> void:
	selected_overlay = overlay
	clear()
	
	for event in selected_overlay.attached_events:
		var event_interface = interface_creator.create_event_interface(self, event)
		
		for action in event.actions:
			interface_creator.create_action_interface(self, event_interface, action)
	
	new_event_button.disabled = false


func clear() -> void:
	new_event_button.disabled = true
	interface_creator.clear()
	selected_event_idx = -1
	selected_action_idx = -1


# Util
func style_interface(interface : PanelContainer, stylebox : StyleBoxFlat) -> void:
	interface.remove_theme_stylebox_override("panel")
	interface.add_theme_stylebox_override("panel", stylebox)


func get_selected_interface(force_event := false) -> PanelContainer:
	if selected_action_idx != -1 and !force_event:
		return interface_creator.get_child(selected_event_idx).action_container.get_child(selected_action_idx)
	elif selected_event_idx != -1:
		return interface_creator.get_child(selected_event_idx)
	return null


func get_event_idx(interface : PanelContainer) -> int:
	while interface.get_parent() != interface_creator:
		interface = interface.get_parent()
	return interface.get_index()


func get_action_idx(interface : PanelContainer, ignore_action : bool) -> int:
	if interface.get_parent() != interface_creator:
		if !ignore_action:
			return interface.get_index()
		else:
			return -1
	else:
		return -1
