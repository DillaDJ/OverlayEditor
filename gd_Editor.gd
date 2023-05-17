class_name Editor
extends Control


@onready var hierarchy : Hierarchy = %Hierarchy
@onready var system_io : SystemIO = %System

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


func _ready() -> void:
	sngl_SaveLoad.connect("save_complete", Callable(system_io, "display_message").bind("Save Complete"))
	%Hierarchy.connect("item_selected", Callable(self, "select_from_path"))
	%Hierarchy.connect("items_deselected", Callable(self, "deselect_overlay"))
	
	selection_stoppers.append($TopMenu/ToggleShow)
	selection_stoppers.append($TopMenu/BGPanel)
	selection_stoppers.append($TopMenu/BGPanel/ButtonLayout/ToggleGrid/GridSettingsBG)
	selection_stoppers.append($TopMenu/BGPanel/ButtonLayout/Save/SaveBG)
	selection_stoppers.append($ChangeMode)
	selection_stoppers.append($RightMenu/ToggleShow)
	selection_stoppers.append($RightMenu/HBoxContainer)
	selection_stoppers.append($PropertySelect)
	selection_stoppers.append($System)
	selection_stoppers.append($Settings)
	selection_stoppers.append($Help)


func _unhandled_input(event) -> void:
	if selected_overlay:
		if event.is_action_pressed("delete"):
			prompt_delete(selected_overlay)
		
		if event.is_action_pressed("duplicate"):
			duplicate_overlay(selected_overlay)
		
		if event.is_action_pressed("left_click"):
			deselect_overlay()
	
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


# Overlay
func register_overlay(overlay : Overlay, parent : Control, to_reset : bool) -> void:
	overlay.name = sngl_Utility.get_unique_name_amongst_siblings(overlay.name, overlay, parent)
	parent.add_child(overlay)
	
	if to_reset:
		reset_overlay(overlay)
	
	overlay_created.emit(overlay)


func duplicate_overlay(overlay : Overlay) -> void:
	var duplicated_overlay = overlay.duplicate()
	register_overlay(duplicated_overlay, overlay_container, true)


func reset_overlay(overlay_to_reset : Overlay):
	var overlays := sngl_Utility.get_nested_children_flat(overlay_to_reset)
	overlays.insert(0, overlay_to_reset)
	
	for overlay in overlays:
		for i in range(overlay.attached_events.size()):
			overlay.attached_events[i] = overlay.attached_events[i].duplicate_event()
			overlay.attached_events[i].match_properties(overlay)
			overlay.attached_events[i].reset(overlay)
			
			connect("events_toggled", Callable(overlay.attached_events[i], "toggle"))


# Selection
func check_for_selections(mouse_pos : Vector2) -> void:
	if !Input.is_action_pressed("alt") and is_point_in_interface(mouse_pos):
		return
	
	var overlays : Array[Node] = sngl_Utility.get_nested_children_flat(overlay_container)
	var selection_group : Array[Node] = []
	overlays.reverse() # Front-to-back selection
	
	for overlay in overlays:
		if overlay.get_global_rect().has_point(mouse_pos):
			selection_group.append(overlay)
	
	if selection_group.size() > 0:
		var selected_idx : int = selection_group.find(selected_overlay)
		
		if selected_idx != -1: # Cycle through selections
			var new_selection : Node = selection_group[(selected_idx + 1) % selection_group.size()]
			if new_selection == selected_overlay:
				return
			click_select_overlay(new_selection)
		else: # Select the first thing
			click_select_overlay(selection_group[0])
	else:
		deselect_overlay()


func click_select_overlay(overlay : Control) -> void:
	select_overlay(overlay)
	overlay_click_selected.emit(overlay)


func select_from_path(path : String) -> void:
	var overlay : Control = overlay_container.get_node(path)
	select_overlay(overlay)

	overlay_hierarchy_selected.emit(overlay)


func select_overlay(overlay : Control) -> void:
	if !overlay.is_connected("hierarchy_order_changed", Callable(hierarchy, "move_overlay_tree_item")):
		overlay.connect("hierarchy_order_changed", Callable(hierarchy, "move_overlay_tree_item").bind(overlay))
	
	selected_overlay = overlay
	overlay_selected.emit(overlay)


func deselect_overlay() -> void:
	if !selected_overlay:
		return
	
	if selected_overlay.is_connected("hierarchy_order_changed", Callable(hierarchy, "move_overlay_tree_item")):
		selected_overlay.disconnect("hierarchy_order_changed", Callable(hierarchy, "move_overlay_tree_item"))
	selected_overlay = null
	
	overlay_deselected.emit()


func is_point_in_interface(point : Vector2) -> bool:
	for interface in selection_stoppers:
		if interface.is_visible_in_tree() and interface.get_global_rect().has_point(point):
			return true
	return false


# Deletion
func prompt_delete(overlay : Node) -> void:
	system_io.prompt_confirmation("Confirm Deletion", "Really delete overlay %s?" % overlay.name)
	system_io.connect("confirmed", Callable(self, "delete_overlay").bind(overlay))
	system_io.connect("unconfirmed", Callable(self, "cancel_delete"))


func delete_overlay(overlay : Node) -> void:
	overlay_deleted.emit()
	overlay.queue_free()
	cancel_delete()


func cancel_delete() -> void:
	system_io.disconnect("confirmed", Callable(self, "delete_overlay"))
	system_io.disconnect("unconfirmed", Callable(self, "cancel_delete"))


# Saving and Loading
func new_scene() -> void:
	deselect_overlay()
	overlay_container.clear()


func prompt_save(save_type : int) -> void:
	var title := ""
	
	if save_type == 0: # SAVE
		var result := sngl_SaveLoad.save_previous()
		
		if result == Error.OK:
			return
	
	if save_type == 0 or save_type == 1:
		if selected_overlay:
			system_io.connect("file_selected", Callable(sngl_SaveLoad, "save_overlay").bind(selected_overlay))
			title = "Save Selected Overlay: %s" % selected_overlay.name
		else:
			system_io.connect("file_selected", Callable(sngl_SaveLoad, "save_scene").bind(overlay_container))
			title = "Save Scene"
	else: # SAVE_SCENE
		system_io.connect("file_selected", Callable(sngl_SaveLoad, "save_scene").bind(overlay_container))
		title = "Save Scene"
	
	system_io.connect("file_selected", Callable(self, "disconnect_file_signals"))
	system_io.connect("file_cancelled", Callable(self, "disconnect_file_signals"))
	system_io.prompt_save_file(title)


func prompt_load(load_type : int) -> void:
	var filters : Array[String] = ["*.tscn", "*.tres"]
	
	match load_type:
		0: # Scene
			system_io.connect("file_selected", Callable(self, "load_scene"))
		1: # Overlay
			system_io.connect("file_selected", Callable(self, "load_overlay"))
	
	system_io.connect("file_selected", Callable(self, "disconnect_file_signals"))
	system_io.connect("file_cancelled", Callable(self, "disconnect_file_signals"))
	system_io.prompt_load_file(filters)


func load_overlay(path : String) -> void:
	var overlay : Overlay = sngl_SaveLoad.load_overlay(path)
	
	if overlay:
		register_overlay(overlay, overlay_container, true)
	else:
		printerr("Error loading overlay")


func load_scene(path : String) -> void:
	new_scene()
	
	var overlays : Array[Overlay] = sngl_SaveLoad.load_scene(path)
	
	if overlays != null:
		for overlay in overlays:
			register_overlay(overlay, overlay_container, true)
	else:
		printerr("Error loading scene")


func disconnect_file_signals(_path : String = ""):
	if system_io.is_connected("file_selected", Callable(sngl_SaveLoad, "save_overlay")):
		system_io.disconnect("file_selected", Callable(sngl_SaveLoad, "save_overlay"))
		
	if system_io.is_connected("file_selected", Callable(sngl_SaveLoad, "save_scene")):
		system_io.disconnect("file_selected", Callable(sngl_SaveLoad, "save_scene"))
	
	if system_io.is_connected("file_selected", Callable(self, "load_overlay")):
		system_io.disconnect("file_selected", Callable(self, "load_overlay"))
		
	if system_io.is_connected("file_selected", Callable(self, "load_scene")):
		system_io.disconnect("file_selected", Callable(self, "load_scene"))
	
	if system_io.is_connected("file_selected", Callable(self, "disconnect_file_signals")):
		system_io.disconnect("file_selected", Callable(self, "disconnect_file_signals"))
	
	if system_io.is_connected("file_cancelled", Callable(self, "disconnect_file_signals")):
		system_io.disconnect("file_cancelled", Callable(self, "disconnect_file_signals"))
