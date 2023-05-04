extends Control


@onready var hierarchy : Control = %Hierarchy


signal hierarchy_cleared()


func _ready():
	var tree = %Hierarchy/Tree
	tree.connect("tree_item_reordered", Callable(self, "move_overlay"))
	connect("hierarchy_cleared", Callable(hierarchy, "clear"))


func move_overlay(from_item : TreeItem, to_item : TreeItem, shift):
	var from_path = hierarchy.get_item_node_path(from_item)
	var from : Overlay = get_node(from_path)
	var old_name := from.name
	var new_idx := 0
	
	if !from:
		printerr("Overlay not found!")
		return
	
	var old_parent = from.get_parent()
	if old_parent != self and old_parent.position_property.is_connected("property_set", Callable(from.position_property, "emit_signal")):
		old_parent.position_property.disconnect("property_set", Callable(from.position_property, "emit_signal"))
	
	if shift == -100:
		from.reparent(self)
		move_child(from, -1)
		from.set_overlay_name(old_name)
		return
	
	var to_path = hierarchy.get_item_node_path(to_item)
	var to : Overlay = get_node(to_path)
	var parent
	if shift == 0:
		new_idx = to.get_child_count()
		parent = to
		
		to.position_property.connect("property_set", Callable(from.position_property, "emit_signal").bind("property_set"))
		
	else:
		if to_item.get_child_count() > 0 and shift == 1:
			parent = to
		else: # For cases when dragging between items at the same layer
			parent = to.get_parent()
	
	from.reparent(parent)
	parent.move_child(from, new_idx)
	from.set_overlay_name(old_name)


func clear():
	for overlay in get_children():
		overlay.queue_free()
	hierarchy_cleared.emit()
