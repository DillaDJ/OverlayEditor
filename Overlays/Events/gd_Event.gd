class_name Event


var trigger : Trigger

var actions : Array[Action] = []


func _init(event_trigger : Trigger):
	trigger = event_trigger
	
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
