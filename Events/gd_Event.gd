class_name Event
extends Resource


@export var trigger : Trigger = null
@export var actions : Array[Action] = []
var properties 		: Array[Property] = []

var enabled = false


func _init(is_enabled : bool = false):
	enabled = is_enabled


func toggle(value : bool):
	enabled = value
	
	if trigger != null:
		trigger.enabled = enabled


# Setup
func attach_trigger(event_trigger : Trigger):
	trigger = event_trigger
	trigger.enabled = enabled
	
	match trigger.type:
		Trigger.Type.TIMED:
			Property.create_read(properties, "Time Remaining", TYPE_FLOAT, Callable(trigger, "get_time"))
		
		Trigger.Type.PROPERTY:
			if trigger.value_container == null:
				trigger.value_container = VariantDataContainer.new()
		
		Trigger.Type.TWITCH_CHAT:
			Property.create_read(properties, "Username", TYPE_STRING, Callable(trigger, "get_message_user"))
			Property.create_read(properties, "Username Color", TYPE_COLOR, Callable(trigger, "get_message_user_color"))
			Property.create_read(properties, "Chat Message", TYPE_STRING_NAME, Callable(trigger, "get_message_contents"))
	
	if !trigger.is_connected("triggered", Callable(self, "execute_actions")):
		trigger.connect("triggered", Callable(self, "execute_actions"))


func reset(overlay : Overlay):
	trigger.reset(overlay)
	
	for action in actions:
		action.reset(overlay)


func match_properties(overlay : Overlay):
	trigger.match_properties(overlay)
	
	for action in actions:
		action.match_properties(overlay)


# Event
func duplicate_event() -> Event:
	var duplicated_event := Event.new(enabled)
	
	duplicated_event.attach_trigger(trigger.duplicate(true))
	
	for action in actions:
		duplicated_event.add_action(action.duplicate(true))
	
	return duplicated_event


func execute_actions() -> void:
	for action in actions:
		action.execute()
		
		if action.type == Action.Type.WAIT:
			await(action.timer.timeout)
			continue


func add_action(action : Action) -> void:
	actions.append(action)


func remove_action(action : Action) -> void:
	actions.erase(action)


func remove_action_at(action_idx : int) -> void:
	actions.remove_at(action_idx - 1)


func delete():
	actions.clear()
	trigger = null
