class_name SceneData
extends Resource


@export var overlay_data : Array[OverlayData] = []


func add_overlay_data(data : OverlayData) -> void:
	overlay_data.append(data)


static func load_scene(path : String) -> Resource:
	if ResourceLoader.exists(path):
		var scene_data = ResourceLoader.load(path)
		if scene_data is SceneData:
			return scene_data
	return null
