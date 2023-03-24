class_name Editor
extends Node


enum EditingTools { MOVE }

@onready var confimation 	: Confirmation = %ConfirmationDialog

@onready var move_tool 			: MoveTool = %MoveTool
@onready var overlay_container 	: Control = %OverlayElements


signal overlay_created(overlay)
signal overlay_deleted()


func _unhandled_input(event):
	if event.is_action_pressed("delete"):
		var selected_overlay = move_tool.selected_overlay
		
		if selected_overlay:
			confimation.prompt("Confirm Deletion", "Really delete overlay %s?" % selected_overlay.name)
			confimation.connect("confirmed", Callable(self, "delete_overlay").bind(selected_overlay))
			confimation.connect("canceled", Callable(self, "stop_delete").bind(selected_overlay))
	elif event.is_action_pressed("duplicate"):
		var selected_overlay = move_tool.selected_overlay
		var new_overlay = selected_overlay.duplicate()
		
		overlay_container.add_child(new_overlay)
		
		overlay_created.emit(new_overlay)


func delete_overlay(overlay):
	overlay_deleted.emit()
	overlay.queue_free()
	
	stop_delete()


func stop_delete():
	confimation.disconnect("confirmed", Callable(self, "delete_overlay"))
	confimation.disconnect("canceled", Callable(self, "stop_delete"))
