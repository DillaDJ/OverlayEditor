extends Control


func _ready():
	%Hierarchy/Tree.connect("tree_item_reordered", Callable(self, "rearrange_overlay_hirarchy"))


func rearrange_overlay_hirarchy(from_item, to_item, shift):
	var from_idx = from_item.get_index()
	var to_idx = to_item.get_index()
	
	var from = get_child(from_idx)
	
	if shift == 0:
		from.reparent(get_child(to_idx))
	else:
		move_child(from, to_idx)
