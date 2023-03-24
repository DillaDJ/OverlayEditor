extends Control


@onready var hierarchy : Control = %Hierarchy


func _ready():
	%Hierarchy/Tree.connect("tree_item_reordered", Callable(self, "rearrange_overlay_hierarchy"))


func rearrange_overlay_hierarchy(from_item : TreeItem, to_item : TreeItem, shift):
	var from_path = hierarchy.get_item_node_path(from_item)
	var from = get_node(from_path)
	var new_idx := 0
	
	if !from:
		print("???")
		return
	
	if shift == -100:
		from.reparent(self)
		move_child(from, -1)
		return
	
	var to_path = hierarchy.get_item_node_path(to_item)
	var to = get_node(to_path)
	
	# print(from_path, " ", to_path, " ", shift)
	
	var parent
	if shift == 0:
		new_idx = to.get_child_count()
		parent = to
	else:
		if to_item.get_child_count() > 0 and shift == 1:
			parent = to
		else: # For cases when dragging between items at the same layer
			parent = to.get_parent()
	
	from.reparent(parent)
	parent.move_child(from, new_idx)
