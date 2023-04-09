class_name SaveLoad
extends Node


signal save_complete()


# Saving
func save_overlay(overlay : Overlay, path : String) -> void:
	var overlay_data := OverlayData.new()
	
	overlay_data.pack_overlay(overlay)
	ResourceSaver.save(overlay_data, "%s.tres" % path)
	
	save_complete.emit()


# Loading
func load_overlay(path : String):
	var _loaded_overlay_data = OverlayData.load_overlay(path)
	
#	if loaded_overlay_data.has_method("pack_overlay"):
#		var overlay = load_overlay(loaded_overlay_data, overlay_container)
#		overlay_created.emit(overlay)
#
#
#func load_overlay(overlay_data : OverlayData, parent) -> Overlay:
#	var overlay : Overlay = overlay_data.packed_scene.instantiate()
#	parent.add_child(overlay)
#
#	for event in overlay.attached_events:
#		event.reset(overlay)
#
#	for child_data in overlay_data.child_overlay_data:
#		load_overlay(child_data, overlay)
#
#	return overlay
