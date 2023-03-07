extends Tree


var preview_scn : PackedScene = preload("res://Utility/scn_TreePreview.tscn")

signal tree_item_reordered(item, to_item, shift)


func _get_drag_data(_at_position : Vector2) -> Variant:
	set_drop_mode_flags(DROP_MODE_INBETWEEN | DROP_MODE_ON_ITEM)
	
	var tree_item : TreeItem = get_selected()
	if !tree_item:
		return
	
	var preview : Control = preview_scn.instantiate()
	preview.set_text(tree_item.get_text(0))
	set_drag_preview(preview)
	
	return tree_item


func _can_drop_data(_pos : Vector2, data : Variant) -> bool:
	return data is TreeItem


func _drop_data(pos : Vector2, item : Variant) -> void:
	var to_item : TreeItem = get_item_at_position(pos)
	var shift : int = get_drop_section_at_position(pos)
	# shift == 0 if dropping on item, -1, +1 if in between
	
	if item == to_item:
		print(item, " ", to_item, " ", shift)
		return
	
	if item.get_parent() == to_item and shift == 1:
		return
	
	emit_signal('tree_item_reordered', item, to_item, shift)
	drop_tree_item(item, to_item, shift)


func drop_tree_item(item : TreeItem, to_item, shift):
	match shift:
		-100:
			item.move_after(get_root().get_child(get_child_count() - 1))
		
		-1:
			item.move_before(to_item)
		
		0:
			var child = to_item.create_child()
			child.set_text(0, item.get_text(0))
			
			item.free()
		
		1:
			item.move_after(to_item)
