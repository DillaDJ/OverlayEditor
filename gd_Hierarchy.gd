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
	move_tool.connect("overlay_click_selected", Callable(self, "find_overlay_in_tree"))
	move_tool.connect("overlay_deselected", Callable(tree, "deselect_all"))
	
	tree.connect("item_selected", Callable(self, "emit_selected_path"))
	tree.connect("empty_clicked", Callable(self, "deselect_all"))

	root = tree.create_item()
	root.set_text(0, "Root")


func add_to_tree(overlay : Control) -> void:
	var new_item : TreeItem = tree.create_item()
	new_item.set_text(0, overlay.name)
	
	overlay.connect("name_changed", Callable(self, "update_item_text").bind(new_item))


func find_overlay_in_tree(overlay : Control) -> void:
	var path : Array [int] = []
	
	while overlay != overlay_container:
		path.append(overlay.get_index())
		overlay = overlay.get_parent()
	selected_by_overlay = true
	
	path.reverse()
	select_by_index(path)


func select_by_index(path : Array[int]) -> void:
	var to_select : TreeItem = root.get_child(path[0])
	
	for i in range(1, path.size()):
		to_select = to_select.get_child(path[i])
	
	to_select.select(0)


func deselect_all(_mouse_pos : Vector2, _mouse_btn_idx : int) -> void:
	tree.deselect_all()
	emit_signal("items_deselected")


func emit_selected_path() -> void:
	if selected_by_overlay:
		selected_by_overlay = false
		return
	
	var item : TreeItem = tree.get_selected()
	var path := get_item_path(item)
	
	item_selected.emit(path)


func get_item_path(item : TreeItem) -> String:
	var path := ""
	
	while item != root:
		path = item.get_text(0) + "/" + path
		item = item.get_parent()
	
	return path


func update_item_text(new_name : String, item : TreeItem) -> void:
	item.set_text(0, new_name)
