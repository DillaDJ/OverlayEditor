extends Panel


@onready var tree : Tree = $Tree

var root : TreeItem

signal item_selected(idx)
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


func select_by_overlay(overlay : Control):
	select_by_index(overlay.get_index())


func select_by_index(idx):
	root.get_children()[idx].select(0)


func deselect_all(_mouse_pos, _mouse_btn_idx):
	tree.deselect_all()


func emit_selected_idx():
	emit_signal("item_selected", tree.get_selected().get_index())
