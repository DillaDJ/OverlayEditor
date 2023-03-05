extends Panel


@onready var tree : Tree = $Tree

var root : TreeItem

signal item_selected(idx)
signal child_selected(parent, idx)

signal items_deselected()


func _ready():
	%OverlayElements.connect("child_entered_tree", Callable(self, "add_to_tree"))
	%MoveTool.connect("overlay_selected", Callable(self, "select_by_overlay"))
	%MoveTool.connect("overlay_deselected", Callable(tree, "deselect_all"))
	
	tree.connect("item_selected", Callable(self, "emit_selected_idx"))
	tree.connect("empty_clicked", Callable(self, "deselect_all"))

	root = tree.create_item()
	root.set_text(0, "Root")


func add_to_tree(overlay):
	var new_item : TreeItem = tree.create_item()
	new_item.set_text(0, overlay.name)
	
	overlay.connect("name_changed", Callable(self, "update_item_text").bind(new_item))


func select_by_overlay(overlay : Control):
	if overlay.get_parent() == %OverlayElements:
		select_by_index(overlay.get_index())
	else:
		select_child_by_index(overlay.get_parent().get_index(), overlay.get_index())


func select_by_index(idx):
	root.get_children()[idx].select(0)


func select_child_by_index(parent_idx, child_idx):
	root.get_children()[parent_idx].get_children()[child_idx].select(0)


func deselect_all(_mouse_pos, _mouse_btn_idx):
	tree.deselect_all()
	emit_signal("items_deselected")


func emit_selected_idx():
	var item : TreeItem = tree.get_selected()
	
	if item.get_parent() != root:
		emit_signal("child_selected", item.get_parent().get_index(), item.get_index())
	else:
		emit_signal("item_selected", item.get_index())


func update_item_text(new_name, item):
	item.set_text(0, new_name)
