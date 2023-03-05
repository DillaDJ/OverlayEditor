extends Tree


var preview_scn : PackedScene = preload("res://Utility/scn_TreePreview.tscn")

signal tree_item_reordered(item, to_item, shift)


func _get_drag_data(_at_position):
	set_drop_mode_flags(DROP_MODE_INBETWEEN | DROP_MODE_ON_ITEM)
	
	var tree_item = get_selected()
	var preview = preview_scn.instantiate()
	preview.set_text(tree_item.get_text(0))
	set_drag_preview(preview)
	
	return tree_item


func _can_drop_data(_pos, data):
	return data is TreeItem


func _drop_data(pos, item):
	var to_item = get_item_at_position(pos)
	var shift = get_drop_section_at_position(pos)
	# shift == 0 if dropping on item, -1, +1 if in between
	
	emit_signal('tree_item_reordered', item, to_item, shift)
	drop_tree_item(item, to_item, shift)


func drop_tree_item(item, to_item, shift):
	match shift:
		-1:
			item.move_before(to_item)
		
		0:
			pass
		
		1:
			item.move_after(to_item)
