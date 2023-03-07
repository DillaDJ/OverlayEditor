extends Panel


class Event:
	var handler
	
	func _init(event_handler):
		handler = event_handler


signal message_sent()


func _ready():
	$VBoxContainer/CreateEvent.connect("button_down", Callable(self, "create_event"))


func create_event():
	var _event = Event.new(self)
