extends Control


@onready var hierarchy : Control = %Hierarchy


func _ready():
	%Hierarchy/Tree.connect("tree_item_reordered", Callable(self, "rearrange_overlay_hirarchy"))


func rearrange_overlay_hirarchy(from_item : TreeItem, to_item : TreeItem, shift):
	var from_path = hierarchy.get_item_path(from_item)
	var from = get_node(from_path)
	
	if !from:
		print("???")
		return
	
	if shift == -100:
		from.reparent(self)
		move_child(from, -1)
		return
	
	var to_path = hierarchy.get_item_path(to_item)
	var to = get_node(to_path)
	
	print(from_path, " ", to_path, " ", shift)
	
	var parent
	if shift == 0:
		parent = to
	else:
		if to_item.get_child_count() > 0 and shift == 1:
			parent = to
		else:
			parent = to.get_parent()
	
	from.reparent(parent)
	parent.move_child(from, to.get_index())
