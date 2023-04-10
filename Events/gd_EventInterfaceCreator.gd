class_name EventInterfaceContainer
extends VBoxContainer


@onready var event_interface_scn : PackedScene = preload("res://Events/scn_EventItemInterface.tscn")


func create_event_interface(event_editor : EventEditor, event : Event) -> EventItemInterface:
	var event_interface : EventItemInterface = event_interface_scn.instantiate()
	var burger_button = event_interface.get_node("HorizontalLayout/BurgerButton")
	burger_button.connect("button_down", Callable(event_editor, "select_interface").bind(event_interface))
	
	add_child(event_interface)
	
	event_interface.set_trigger_interface(event.trigger)
	
	return event_interface


func clear() -> void:
	for child in get_children():
		child.queue_free()
