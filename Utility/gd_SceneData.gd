class_name SceneData
extends Resource


@export var scene_overlay_data : Array[OverlayData]


func add_overlay_data(overlay_data : OverlayData) -> void:
	scene_overlay_data.append(overlay_data)


static func load_scene(path : String) -> Resource:
	if ResourceLoader.exists(path):
		return load(path)
	return null
