extends TabContainer


func _can_drop_data(_pos : Vector2, data : Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY


func _drop_data(_pos : Vector2, item : Variant) -> void:
	var from : TabContainer = get_tree().root.get_node(item["from_path"])
	var tab : Control = from.get_child(item["tabc_element"])
	
	tab.reparent(self)
