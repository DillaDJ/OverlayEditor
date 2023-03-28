class_name Editor
extends Node


enum EditingTools { MOVE }

@onready var hierarchy 		:= %Hierarchy

@onready var confimation 	: Confirmation = %ConfirmationDialog

@onready var transform_tool		: TransformTool = %TransformTool
@onready var overlay_container 	: Control = %OverlayElements

var selection_stoppers : Array[Control]

var selected_overlay : Control


signal overlay_created(overlay : Overlay)
signal overlay_deleted()

signal overlay_click_selected(overlay)
signal overlay_hierarchy_selected(overlay)
signal overlay_selected(overlay : Overlay)
signal overlay_deselected()



func _ready():
	%Hierarchy.connect("item_selected", Callable(self, "select_from_path"))
	%Hierarchy.connect("items_deselected", Callable(self, "deselect_overlay"))
	
	selection_stoppers.append(%TopMenu/ToggleShow)
	selection_stoppers.append(%TopMenu/BGPanel)
	selection_stoppers.append(%TopMenu/BGPanel/ButtonLayout/ToggleGrid/GridSettingsBG)
	selection_stoppers.append(%ChangeMode/ToggleShow)
	selection_stoppers.append(%ChangeMode/ToOverlayButton)
	selection_stoppers.append(%HierarchyInspector/ToggleShow)
	selection_stoppers.append(%HierarchyInspector/HBoxContainer)
	selection_stoppers.append(%PropertySelect)


func _unhandled_input(event):
	if selected_overlay:
		if event.is_action_pressed("left_click"):
			deselect_overlay()
		
		if event.is_action_pressed("delete"):
			prompt_delete(selected_overlay)
		
		if event.is_action_pressed("duplicate"):
			duplicate_overlay(selected_overlay)
	
	if event.is_action_pressed("save"):
		save_scene()


func _input(_event):
	if Input.is_action_just_released("left_click"):
		check_for_selections(get_viewport().get_mouse_position())


# Creation
func create_overlay(overlay_scn : PackedScene) -> void:
	var new_overlay : Control = overlay_scn.instantiate()
	new_overlay.name = sngl_Utility.get_unique_name_amongst_siblings(new_overlay.name, new_overlay, overlay_container)
	overlay_container.add_child(new_overlay)
	overlay_created.emit(new_overlay)


func duplicate_overlay(overlay : Overlay) -> void:
	var new_overlay = overlay.duplicate()
	new_overlay.name = sngl_Utility.get_unique_name_amongst_siblings(new_overlay.name, new_overlay, overlay_container)
	overlay_container.add_child(new_overlay)
	
	var old_overlays := sngl_Utility.get_nested_children_flat(overlay)
	var new_overlays := sngl_Utility.get_nested_children_flat(new_overlay)
	old_overlays.insert(0, overlay)
	new_overlays.insert(0, new_overlay)
	
	for i in range(old_overlays.size()):
		for j in range(old_overlays[i].attached_events.size()):
			new_overlays[i].attached_events.append(old_overlays[i].attached_events[j].duplicate())
	
	for new_overlay_i in new_overlays:
		for event in new_overlay.attached_events:
			event.match_properties(new_overlay_i)
	
	overlay_created.emit(new_overlay)


# Selection
func check_for_selections(mouse_pos : Vector2) -> void:
	if !Input.is_action_pressed("alt") and is_point_in_interface(mouse_pos):
		return
	
	var overlays : Array[Node] = sngl_Utility.get_nested_children_flat(overlay_container)
	var selection_group : Array[Node] = []
	overlays.reverse()
	
	for overlay in overlays:
		if overlay.get_global_rect().has_point(mouse_pos):
			selection_group.append(overlay)
	
	if selection_group.size() > 0:
		var selected_idx : int = selection_group.find(selected_overlay)
		
		if selected_idx != -1:
			var new_selection : Node = selection_group[(selected_idx + 1) % selection_group.size()]
			if new_selection == selected_overlay:
				return
			click_select_overlay(new_selection)
		else:
			click_select_overlay(selection_group[0])


func click_select_overlay(overlay : Control) -> void:
	select_overlay(overlay)
	overlay_click_selected.emit(overlay)


func select_overlay(overlay : Control) -> void:
	if !overlay.is_connected("hierarchy_order_changed", Callable(hierarchy, "move_overlay_tree_item")):
		overlay.connect("hierarchy_order_changed", Callable(hierarchy, "move_overlay_tree_item").bind(overlay))
	
	selected_overlay = overlay
	overlay_selected.emit(overlay)


func deselect_overlay() -> void:
	if !selected_overlay:
		return
	
	if selected_overlay.is_connected("hierarchy_order_changed", Callable(%Hierarchy, "move_overlay_tree_item")):
		selected_overlay.disconnect("hierarchy_order_changed", Callable(%Hierarchy, "move_overlay_tree_item"))
	selected_overlay = null
	
	overlay_deselected.emit()


func select_from_path(path : String) -> void:
	var overlay : Control = overlay_container.get_node(path)
	select_overlay(overlay)

	overlay_hierarchy_selected.emit(overlay)


func is_point_in_interface(point : Vector2) -> bool:
	for interface in selection_stoppers:
		if interface.is_visible_in_tree() and interface.get_global_rect().has_point(point):
			return true
	return false


# Deletion
func prompt_delete(overlay : Node) -> void:
	confimation.prompt("Confirm Deletion", "Really delete overlay %s?" % overlay.name)
	confimation.connect("confirmed", Callable(self, "delete_overlay").bind(overlay))
	confimation.connect("canceled", Callable(self, "stop_delete").bind(overlay))


func delete_overlay(overlay : Node) -> void:
	overlay_deleted.emit()
	overlay.queue_free()
	
	stop_delete()


func stop_delete() -> void:
	confimation.disconnect("confirmed", Callable(self, "delete_overlay"))
	confimation.disconnect("canceled", Callable(self, "stop_delete"))


# Saving
func save_scene():
	var saved_scene := PackedScene.new()
	
	var result = saved_scene.pack(overlay_container)
	
	if result == OK:
		var error = ResourceSaver.save(saved_scene, "res://test_saved_scene.tscn")
		if error:
			printerr("Save failed")

