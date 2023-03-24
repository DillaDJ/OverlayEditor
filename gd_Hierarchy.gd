extends Panel


@onready var overlay_container : Control = %OverlayElements
@onready var tree : Tree = $Tree


var root : TreeItem

var selected_by_overlay := false


signal item_selected(path : String)
signal items_deselected()


func _ready() -> void:
	var move_tool = %MoveTool
	
	sngl_Utility.get_scene_root().connect("overlay_created", Callable(self, "add_to_tree"))
	sngl_Utility.get_scene_root().connect("overlay_deleted", Callable(self, "remove_from_tree"))
	move_tool.connect("overlay_click_selected", Callable(self, "select_by_overlay"))
	move_tool.connect("overlay_deselected", Callable(tree, "deselect_all"))
	
	tree.connect("item_selected", Callable(self, "select_by_hierarchy"))
	tree.connect("empty_clicked", Callable(self, "deselect_all"))
	tree.connect("tree_item_created", Callable(self, "reregister_item"))

	root = tree.create_item()
	root.set_text(0, "Root")


# Items
func add_to_tree(overlay : Control) -> void:
	var new_item : TreeItem = tree.create_item()
	new_item.set_text(0, overlay.name)
	
	
	
	overlay.connect("name_changed", Callable(self, "update_item_text").bind(new_item))


func remove_from_tree():
	var item : TreeItem = tree.get_selected()
	item.free()
	
	tree.deselect_all()
	emit_signal("items_deselected")


func reregister_item(item : TreeItem):
	var overlay = overlay_container.get_node(get_item_node_path(item))
	if overlay.is_connected("name_changed", Callable(self, "update_item_text")):
		overlay.disconnect("name_changed", Callable(self, "update_item_text"))
	overlay.connect("name_changed", Callable(self, "update_item_text").bind(item))


func move_overlay_tree_item(idx : int, overlay : Control) -> void:
	var item 		= get_tree_item_from_path(get_overlay_tree_path(overlay))
	var current_idx = item.get_index()
	var parent 		= item.get_parent()
	var to_item 	= parent.get_first_child()
	
	if idx > parent.get_child_count() - 1:
		idx = parent.get_child_count() - 1
	
	#print("Parent: %s, item: %s, to_item: %s" % [parent.get_text(0), item.get_text(0), to_item.get_text(0)])
	for i in range(idx):
		to_item = to_item.get_next()
	
	if idx > current_idx:
		item.move_after(to_item)
	else:
		item.move_before(to_item)


func update_item_text(new_name : String, item : TreeItem) -> void:
	item.set_text(0, new_name)


# Selection
func select_by_hierarchy() -> void:
	if selected_by_overlay:
		selected_by_overlay = false
		return
	
	var item : TreeItem = tree.get_selected()
	var path := get_item_node_path(item)
	
	item_selected.emit(path)


func select_by_overlay(overlay : Control) -> void:
	var path = get_overlay_tree_path(overlay)
	var to_select = get_tree_item_from_path(path)
	to_select.select(0)


func deselect_all(_mouse_pos : Vector2, _mouse_btn_idx : int) -> void:
	tree.deselect_all()
	emit_signal("items_deselected")



# Utility
func get_item_node_path(item : TreeItem) -> String:
	var path := ""
	
	while item != root:
		path = item.get_text(0) + "/" + path
		item = item.get_parent()
	
	return path


func get_overlay_tree_path(overlay : Control) -> Array [int]:
	var path : Array [int] = []
	
	while overlay != overlay_container:
		path.append(overlay.get_index())
		overlay = overlay.get_parent()
	selected_by_overlay = true
	
	path.reverse()
	return path


func get_tree_item_from_path(path : Array[int]) -> TreeItem:
	var item : TreeItem = root.get_child(path[0])
	
	for i in range(1, path.size()):
		item = item.get_child(path[i])
	return item

