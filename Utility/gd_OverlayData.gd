class_name OverlayData
extends Resource


@export var packed_scene : PackedScene
@export var child_overlay_data : Array[OverlayData]


func pack_overlay(overlay : Overlay) -> void:
	packed_scene = PackedScene.new()
	var result = packed_scene.pack(overlay)
	
	if result != OK:
		printerr("Could not pack overlay: %s" % overlay.name)
	
	for child in overlay.get_children():
		var child_overlay := OverlayData.new()
		child_overlay.pack_overlay(child)
		child_overlay_data.append(child_overlay)


static func load_overlay(path : String) -> Resource:
	if ResourceLoader.exists(path):
		return load(path)
	return null
