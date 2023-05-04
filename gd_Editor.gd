class_name Editor
extends Node


@onready var hierarchy 	:= %Hierarchy
@onready var system_io 	:= %System

@onready var transform_tool		: TransformTool = %TransformTool
@onready var overlay_container 	: Control = %OverlayElements

const selection_threshold := 0.2

var selection_stoppers : Array[Control]
var selected_overlay : Control

var mouse_hold_time : float = 0

var events_enabled := false


signal overlay_created(overlay : Overlay)
signal overlay_deleted()

signal overlay_click_selected(overlay)
signal overlay_hierarchy_selected(overlay)
signal overlay_selected(overlay : Overlay)
signal overlay_deselected()

signal events_toggled(value)


func _ready():
	%Hierarchy.connect("item_selected", Callable(self, "select_from_path"))
	%Hierarchy.connect("items_deselected", Callable(self, "deselect_overlay"))
	
	selection_stoppers.append(%TopMenu/ToggleShow)
	selection_stoppers.append(%TopMenu/BGPanel)
	selection_stoppers.append(%TopMenu/BGPanel/ButtonLayout/ToggleGrid/GridSettingsBG)
	selection_stoppers.append(%ChangeMode/ToggleShow)
	selection_stoppers.append(%ChangeMode/ToOverlayButton)
	selection_stoppers.append(%RightMenu/ToggleShow)
	selection_stoppers.append(%RightMenu/HBoxContainer)
	selection_stoppers.append(%PropertySelect)
	selection_stoppers.append(%System)


func _unhandled_input(event):
	if selected_overlay:
		if event.is_action_pressed("left_click"):
			deselect_overlay()
		
		if event.is_action_pressed("delete"):
			prompt_delete(selected_overlay)
		
		if event.is_action_pressed("duplicate"):
			duplicate_overlay(selected_overlay)
	
	if event.is_action_pressed("save"):
		prompt_save(0)
	elif event.is_action_pressed("hard_save"):
		prompt_save(1)
	elif event.is_action_pressed("full_save"):
		prompt_save(2)


func _input(_event):
	if Input.is_action_just_released("left_click"):
		if mouse_hold_time < selection_threshold:
			check_for_selections(get_viewport().get_mouse_position())
		mouse_hold_time = 0


func _process(delta):
	if Input.is_action_pressed("left_click"):
		mouse_hold_time += delta


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
	
	var new_overlays := sngl_Utility.get_nested_children_flat(new_overlay)
	new_overlays.insert(0, new_overlay)
	
	for i in range(new_overlays.size()):
		for j in range(new_overlays[i].attached_events.size()):
			new_overlays[i].attached_events[j] = new_overlays[i].attached_events[j].duplicate_event()
			new_overlays[i].attached_events[j].match_properties(new_overlays[i])
			new_overlays[i].attached_events[j].reset(new_overlays[i])
			
			connect("events_toggled", Callable(new_overlays[i].attached_events[j], "toggle"))
	
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
	system_io.prompt_confirmation("Confirm Deletion", "Really delete overlay %s?" % overlay.name)
	system_io.connect("confirmed", Callable(self, "delete_overlay").bind(overlay))
	system_io.connect("unconfirmed", Callable(self, "stop_delete"))


func delete_overlay(overlay : Node) -> void:
	overlay_deleted.emit()
	overlay.queue_free()
	
	stop_delete()


func stop_delete() -> void:
	system_io.disconnect("confirmed", Callable(self, "delete_overlay"))
	system_io.disconnect("unconfirmed", Callable(self, "stop_delete"))


# Saving and Loading
func new_scene():
	deselect_overlay()
	overlay_container.clear()


func prompt_save(save_type : int) -> void:
	var title := ""
	
	if save_type == 0: # SAVE
		var result := sngl_SaveLoad.save_previous()
			
		if result != "":
			system_io.display_message("Save Successful", result)
			return
	
	if save_type == 0 or save_type == 1:
		if selected_overlay:
			system_io.connect("file_selected", Callable(sngl_SaveLoad, "save_overlay").bind(selected_overlay))
			title = "Save Selected Overlay: %s" % selected_overlay.name
		else:
			system_io.connect("file_selected", Callable(sngl_SaveLoad, "save_scene").bind(overlay_container, "Save Scene"))
			title = "Save Scene"
	else: # SAVE_SCENE
		system_io.connect("file_selected", Callable(sngl_SaveLoad, "save_scene").bind(selected_overlay, "Save Scene"))
		title = "Save Scene"
	
	system_io.connect("file_cancelled", Callable(self, "disconnect_file_signals"))
	system_io.prompt_save_file(title)


func prompt_load(load_type : int):
	var filters : Array[String] = ["*.tscn", "*.tres"]
	
	match load_type:
		0: # Scene
			system_io.connect("file_selected", Callable(self, "load_scene"))
		1: # Overlay
			system_io.connect("file_selected", Callable(self, "load_overlay"))
	
	system_io.connect("file_cancelled", Callable(self, "disconnect_file_signals"))
	system_io.prompt_load_file(filters)


func load_overlay(path : String):
	var overlay = sngl_SaveLoad.load_overlay_into_scene(path, overlay_container)
	overlay_created.emit(overlay)
	
	disconnect_file_signals()


func load_scene(path : String):
	new_scene()
	sngl_SaveLoad.load_scene_to_container(path, overlay_container)
	
	for overlay in overlay_container.get_children():
		overlay_created.emit(overlay)
	
	disconnect_file_signals()


func disconnect_file_signals():
	if system_io.is_connected("file_selected", Callable(sngl_SaveLoad, "save_overlay")):
		system_io.disconnect("file_selected", Callable(sngl_SaveLoad, "save_overlay"))
		
	if system_io.is_connected("file_selected", Callable(sngl_SaveLoad, "save_scene")):
		system_io.disconnect("file_selected", Callable(sngl_SaveLoad, "save_scene"))
	
	if system_io.is_connected("file_selected", Callable(sngl_SaveLoad, "load_overlay")):
		system_io.disconnect("file_selected", Callable(sngl_SaveLoad, "load_overlay"))
	
	if system_io.is_connected("file_cancelled", Callable(self, "disconnect_file_signals")):
		system_io.disconnect("file_cancelled", Callable(self, "disconnect_file_signals"))


func toggle_events():
	events_enabled = !events_enabled
	events_toggled.emit(events_enabled)
