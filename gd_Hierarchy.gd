extends Panel

@onready var panel_icon : Texture2D = preload("res://Icons/panel.png")
@onready var texture_icon : Texture2D = preload("res://Icons/texturerect.png")
@onready var text_icon : Texture2D = preload("res://Icons/text.png")
@onready var rich_text_icon : Texture2D = preload("res://Icons/rich-text.png")
@onready var hbox_icon : Texture2D = preload("res://Icons/hlayout.png")
@onready var vbox_icon : Texture2D = preload("res://Icons/vlayout.png")
@onready var grid_icon : Texture2D = preload("res://Icons/gridlayout.png")

@onready var overlay_container : Control = %OverlayElements
@onready var tree : Tree = $Tree

var root : TreeItem

var selected_by_overlay := false


signal item_selected(path : String)
signal items_deselected()


func _ready() -> void:
	var editor = sngl_Utility.get_scene_root()
	
	editor.connect("overlay_created", Callable(self, "add_to_tree"))
	editor.connect("overlay_deleted", Callable(self, "remove_from_tree"))
	editor.connect("overlay_click_selected", Callable(self, "select_by_overlay"))
	editor.connect("overlay_deselected", Callable(tree, "deselect_all"))
	
	tree.connect("item_selected", Callable(self, "select_by_hierarchy"))
	tree.connect("empty_clicked", Callable(self, "deselect_all"))
	tree.connect("tree_item_created", Callable(self, "reregister_item"))

	root = tree.create_item()
	root.set_text(0, "Root")


# Items
func add_to_tree(overlay : Overlay) -> void:
	var deep_children = sngl_Utility.get_nested_children(overlay)
	var new_item : TreeItem = tree.create_item(root)
	new_item.set_text(0, overlay.name)
	set_item_icon(overlay.type, new_item)
	
	if deep_children.size() > 0:
		add_children_to_tree(new_item, deep_children)
	
	overlay.connect("name_changed", Callable(self, "update_item_text").bind(new_item))


# child_array[0] can never be an array, see: sngl_Utility.get_nested_children()
func add_children_to_tree(parent : TreeItem, child_array : Array) -> void:
	var new_child_item
	
	for child in child_array:
		if typeof(child) == TYPE_ARRAY:
			add_children_to_tree(new_child_item, child)
		else:
			new_child_item = parent.create_child()
			new_child_item.set_text(0, child.name)
			set_item_icon(child.type, new_child_item)
			
			child.connect("name_changed", Callable(self, "update_item_text").bind(new_child_item))


func remove_from_tree():
	var item : TreeItem = tree.get_selected()
	item.free()
	
	tree.deselect_all()
	emit_signal("items_deselected")


func clear():
	if root.get_child_count() == 0:
		return
	
	var next_child := root.get_child(0)
	var child = next_child
	
	while next_child:
		child = next_child
		next_child = child.get_next()
		
		child.free()


func reregister_item(item : TreeItem):
	var overlay = overlay_container.get_node(get_item_node_path(item))
	
	if overlay and overlay.is_connected("name_changed", Callable(self, "update_item_text")):
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


func set_item_icon(overlay_type : Overlay.Type, item : TreeItem) -> void:
	match overlay_type:
		Overlay.Type.PANEL:
			item.set_icon(0, panel_icon)
		Overlay.Type.TEXTURE_PANEL:
			item.set_icon(0, texture_icon)
		Overlay.Type.TEXT:
			item.set_icon(0, text_icon)
		Overlay.Type.RICH_TEXT:
			item.set_icon(0, rich_text_icon)
		Overlay.Type.HBOX:
			item.set_icon(0, hbox_icon)
		Overlay.Type.VBOX:
			item.set_icon(0, vbox_icon)
		Overlay.Type.GRID:
			item.set_icon(0, grid_icon)
	
	item.set_icon_max_width(0, 20)
