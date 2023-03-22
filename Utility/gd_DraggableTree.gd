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


func drop_tree_item(item : TreeItem, to_item : TreeItem, shift : int):
	match shift:
		-100:
			item.move_after(get_root().get_child(get_child_count() - 1))
		
		-1:
			item.move_before(to_item)
		
		0:
			var child := reparent_tree_item(item, to_item)
		
		1:
			if to_item.get_child_count() != 0:
				var child := reparent_tree_item(item, to_item)
				child.move_before(to_item.get_child(0))
				
			else:
				item.move_after(to_item)


func reparent_tree_item(tree_item : TreeItem, new_parent : TreeItem) -> TreeItem:
	var child : TreeItem = new_parent.create_child()
	child.set_text(0, tree_item.get_text(0))
				
	populate_deep_children_items(tree_item, child)
	
	tree_item.free()
	
	return child


func populate_deep_children_items(from : TreeItem, to : TreeItem) -> void:
	for child in from.get_children():
		var new_child = to.create_child(0)
		new_child.set_text(0, child.get_text(0))
		
		populate_deep_children_items(child, new_child)
