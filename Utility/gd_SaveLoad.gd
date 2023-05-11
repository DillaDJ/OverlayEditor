class_name SaveLoad
extends Node


var previous_overlay : Overlay = null
var previous_scene : Control = null
var previous_path : String = ""

var last_result : String = ""


signal save_complete(result : String)


# Saving
func save_overlay(path : String, overlay : Overlay) -> void:
	var overlay_data := OverlayData.new()
	
	overlay_data.pack_overlay(overlay)
	ResourceSaver.save(overlay_data, "%s.overlay.tres" % path)
	
	previous_overlay = overlay
	previous_path = path
	
	save_complete.emit("Saved Overlay: %s" % previous_overlay.name)


func save_scene(path : String, scene : Control) -> void:
	var scene_data := SceneData.new()
	
	for overlay in scene.get_children():
		var overlay_data := OverlayData.new()
		overlay_data.pack_overlay(overlay)
		
		scene_data.add_overlay_data(overlay_data)
	
	ResourceSaver.save(scene_data, "%s.scene.tres" % path)
	
	previous_scene = scene
	previous_path = path
	
	save_complete.emit("Saved Scene")


func save_previous() -> Error:
	if (previous_overlay == null and previous_scene == null) or previous_path == "":
		return Error.FAILED
	
	if previous_overlay != null:
		save_overlay(previous_path, previous_overlay)
	elif previous_scene != null:
		save_scene(previous_path, previous_scene)
	save_complete.emit("Saved Overlay: %s" % previous_overlay.name if previous_overlay != null else "Saved Scene")
	return Error.OK


# Loading
func load_overlay(path : String) -> Overlay:
	var data = OverlayData.load_overlay(path)
	var overlay : Overlay = data.packed_scene.instantiate()
	
	for child_data in data.child_data:
		load_children_from_data(child_data, overlay)
	return overlay


func load_scene(path : String) -> Array[Overlay]:
	var scene_data = SceneData.load_scene(path)
	var overlays : Array[Overlay] = []
	
	for overlay_data in scene_data.overlay_data:
		var overlay = overlay_data.packed_scene.instantiate()
		for child_data in overlay_data.child_data:
			load_children_from_data(child_data, overlay)
		overlays.append(overlay)
	
	return overlays


func load_children_from_data(data : OverlayData, parent : Overlay) -> void:
	var overlay : Overlay = data.packed_scene.instantiate()
	parent.add_child(overlay)
	
	for child_data in data.child_data:
		load_children_from_data(child_data, overlay)
