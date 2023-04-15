class_name SaveLoad
extends Node


var previous_overlay : Overlay = null
var previous_scene : Control = null
var previous_path : String = ""

var last_result : String = ""

signal save_complete()


# Saving
func save_scene(path : String, scene : Control) -> void:
	var scene_data := SceneData.new()
	
	for overlay in scene.get_children():
		var overlay_data := OverlayData.new()
		overlay_data.pack_overlay(overlay)
		
		scene_data.add_overlay_data(overlay_data)
	
	ResourceSaver.save(scene_data, "%s.scene.tres" % path, ResourceSaver.FLAG_CHANGE_PATH)
	
	previous_scene = scene
	previous_path = path
	
	last_result = "Saved Scene" % previous_overlay.name
	save_complete.emit()


func save_overlay(path : String, overlay : Overlay) -> void:
	var overlay_data := OverlayData.new()
	
	overlay_data.pack_overlay(overlay)
	ResourceSaver.save(overlay_data, "%s.overlay.tres" % path)
	
	previous_overlay = overlay
	previous_path = path
	
	last_result = "Saved Overlay: %s" % previous_overlay.name
	save_complete.emit()
	


func save_previous() -> String:
	if (previous_overlay == null and previous_scene == null) or previous_path == "":
		return ""
	
	if previous_overlay != null:
		save_overlay(previous_path, previous_overlay)
	elif previous_scene != null:
		save_scene(previous_path, previous_scene)
	return "Saved Overlay: %s" % previous_overlay.name if previous_overlay != null else "Saved Scene"


# Loading
func load_overlay(path : String) -> OverlayData:
	var loaded_overlay_data = OverlayData.load_overlay(path)
	return loaded_overlay_data


func add_overlay_to_scene(overlay_data : OverlayData, parent : Control) -> Overlay:
	var overlay : Overlay = overlay_data.packed_scene.instantiate()
	overlay.name = sngl_Utility.get_unique_name_amongst_siblings(overlay.name, overlay, parent)
	parent.add_child(overlay)
	
	for i in range(overlay.attached_events.size()):
		overlay.attached_events[i] = overlay.attached_events[i].duplicate_event()
		overlay.attached_events[i].match_properties(overlay)
		overlay.attached_events[i].reset(overlay)
	
	for event in overlay.attached_events:
		event = event.duplicate_event()
		event.match_properties(overlay)
		event.reset(overlay)
	
	for child_data in overlay_data.child_overlay_data:
		add_overlay_to_scene(child_data, overlay)
	
	return overlay


func load_overlay_into_scene(path : String, parent : Control) -> Overlay:
	var overlay_data := load_overlay(path)
	return add_overlay_to_scene(overlay_data, parent)


func load_scene(path : String) -> SceneData:
	var loaded_overlay_data = OverlayData.load_overlay(path)
	return loaded_overlay_data


func load_scene_to_container(path : String, scene_container : Control) -> void:
	var scene_data := load_scene(path)
	
	for overlay_data in scene_data.scene_overlay_data:
		add_overlay_to_scene(overlay_data, scene_container)
