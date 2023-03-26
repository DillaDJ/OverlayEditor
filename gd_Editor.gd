class_name Editor
extends Node


enum EditingTools { MOVE }

@onready var confimation 	: Confirmation = %ConfirmationDialog

@onready var move_tool 			: MoveTool = %MoveTool
@onready var overlay_container 	: Control = %OverlayElements


signal overlay_created(overlay : Control)
signal overlay_deleted()


func _unhandled_input(event):
	if event.is_action_pressed("delete") and move_tool.selected_overlay:
		prompt_delete(move_tool.selected_overlay)
	
	elif event.is_action_pressed("duplicate"):
		duplicate_overlay(move_tool.selected_overlay)


# Deletion
func prompt_delete(overlay : Node) -> void:
	confimation.prompt("Confirm Deletion", "Really delete overlay %s?" % overlay.name)
	confimation.connect("confirmed", Callable(self, "delete_overlay").bind(overlay))
	confimation.connect("canceled", Callable(self, "stop_delete").bind(overlay))


func delete_overlay(overlay : Node) -> void:
	overlay_deleted.emit()
	overlay.queue_free()
	
	stop_delete()


func stop_delete() -> void:
	confimation.disconnect("confirmed", Callable(self, "delete_overlay"))
	confimation.disconnect("canceled", Callable(self, "stop_delete"))


# Creation
func create_overlay(overlay_scn : PackedScene) -> void:
	var new_overlay : Control = overlay_scn.instantiate()
	overlay_container.add_child(new_overlay)
	overlay_created.emit(new_overlay)


# Duplication
func duplicate_overlay(overlay : Overlay) -> void:
	var new_overlay = overlay.duplicate()
	overlay_container.add_child(new_overlay)
	
	var old_overlays := sngl_Utility.get_nested_children_flat(overlay)
	var new_overlays := sngl_Utility.get_nested_children_flat(new_overlay)
	old_overlays.insert(0, overlay)
	new_overlays.insert(0, new_overlay)
	
	for i in range(old_overlays.size()):
		for j in range(old_overlays[i].attached_events.size()):
			new_overlays[i].attached_events.append(old_overlays[i].attached_events[j].duplicate(new_overlays[i]))
	
	overlay_created.emit(new_overlay)

