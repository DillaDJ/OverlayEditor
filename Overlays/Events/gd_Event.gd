class_name Event


var trigger : Trigger

var properties : Array[Property]

var actions : Array[Action] = []


func _init(event_trigger : Trigger):
	trigger = event_trigger
	
	match trigger.type:
		Trigger.Type.TIMED:
			properties.append(Property.new("Timer Length", Property.Type.FLOAT, Callable(trigger, "get_time")))
		
		Trigger.Type.TWITCH_CHAT:
			properties.append(Property.new("Chatter Username", Property.Type.STRING_SHORT, Callable(trigger, "get_message_user")))
			properties.append(Property.new("Chat Message", Property.Type.STRING, Callable(trigger, "get_message_contents")))
	
	trigger.connect("triggered", Callable(self, "execute_actions"))


func add_action(action : Action) -> void:
	actions.append(action)


func remove_action(action : Action) -> void:
	actions.erase(action)


func remove_action_at(action_idx : int) -> void:
	actions.remove_at(action_idx - 1)


func execute_actions() -> void:
	for action in actions:
		action.execute()
