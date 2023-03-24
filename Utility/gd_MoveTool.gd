class_name  MoveTool
extends Control


@onready var grid : OverlayGrid = %Grid

# Resize gizmo order
# 0 1 2
# 7 * 3
# 6 5 4
@onready var resize_gizmos : Array[Node] = $ResizeGizmos.get_children()
@onready var translation_gizmo : Button = $TranslationGizmo

var enabled := true

var selection_stoppers : Array[Control]

var selected_overlay : Control

var dragging_gizmo : Control
var mouse_pos : Vector2

# Gizmos that are following another gizmo as a result of moving it
var h_following : Array[Control] = []
var v_following : Array[Control] = []

var clicked_offset : Vector2
var click_time : float = 0
var click_time_threshold := 0.2

var translating 	:= false
var just_selected 	:= false

signal overlay_click_selected(overlay)
signal overlay_selected(overlay)
signal overlay_deselected()

signal overlay_translated(overlay_position)
signal overlay_resized(overlay_size)


func _ready() -> void:
	var resize_gizmo_nodes : Array[Node] = $ResizeGizmos.get_children()
	for i in range(resize_gizmo_nodes.size()):
		resize_gizmo_nodes[i].connect("button_down", Callable(self, "start_resize").bind(i))
		resize_gizmo_nodes[i].connect("button_up", Callable(self, "stop_resize"))
	
	translation_gizmo.connect("button_down", Callable(self, "start_translate"))
	translation_gizmo.connect("button_up", Callable(self, "stop_translate"))
	
	selection_stoppers.append(%TopMenu/ToggleShow)
	selection_stoppers.append(%TopMenu/BGPanel)
	selection_stoppers.append(%TopMenu/BGPanel/ButtonLayout/ToggleGrid/GridSettingsBG)
	selection_stoppers.append(%ChangeMode/ToggleShow)
	selection_stoppers.append(%ChangeMode/ToOverlayButton)
	selection_stoppers.append(%HierarchyInspector/ToggleShow)
	selection_stoppers.append(%HierarchyInspector/HBoxContainer)
	
	%Hierarchy.connect("item_selected", Callable(self, "select_from_path"))
	%Hierarchy.connect("items_deselected", Callable(self, "deselect_overlay"))


func _unhandled_input(_event : InputEvent) -> void:
	if enabled and Input.is_action_just_pressed("left_click") and selected_overlay:
		deselect_overlay()


func _process(delta : float) -> void:
	# Skip a frame so that properties don't get applied to hierarchy selects
	if just_selected:
		just_selected = false
		return
	
	if enabled:
		mouse_pos = get_viewport().get_mouse_position()
		
		if Input.is_action_pressed("left_click"):
			translate_and_resize()
			click_time += delta
		
		if Input.is_action_just_released("left_click"):
			if click_time < click_time_threshold:
				check_for_selections()
			
			click_time = 0


func toggle_enabled():
	enabled = !enabled


# Selection
func check_for_selections() -> void:
	if is_mouse_hovering_interface():
		return
	
	var selection_group : Array[Node] = []
	var overlays : Array[Node] = sngl_Utility.get_children_nested(%OverlayElements)
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
	if !overlay.is_connected("transformed", Callable(self, "reposition_gizmos")):
		overlay.connect("transformed", Callable(self, "reposition_gizmos"))
	
	if !overlay.is_connected("hierarchy_order_changed", Callable(%Hierarchy, "move_overlay_tree_item")):
		overlay.connect("hierarchy_order_changed", Callable(%Hierarchy, "move_overlay_tree_item").bind(overlay))
	
	selected_overlay = overlay
	
	reposition_gizmos()
	show()
	
	overlay_selected.emit(overlay)


func deselect_overlay() -> void:
	if selected_overlay and selected_overlay.is_connected("transformed", Callable(self, "reposition_gizmos")):
		selected_overlay.disconnect("transformed", Callable(self, "reposition_gizmos"))
		
	if selected_overlay.is_connected("hierarchy_order_changed", Callable(%Hierarchy, "move_overlay_tree_item")):
		selected_overlay.disconnect("hierarchy_order_changed", Callable(%Hierarchy, "move_overlay_tree_item"))
	selected_overlay = null
	
	overlay_deselected.emit()
	hide()


func select_from_path(path : String) -> void:
	var overlay : Control = %OverlayElements.get_node(path)
	select_overlay(overlay)
	just_selected = true


# Resize and translate
func translate_and_resize() -> void:
	var new_pos : Vector2 = mouse_pos + clicked_offset
	
	if grid.is_visible:
		new_pos = grid.snap_to_nearest_point(new_pos)
	
	if dragging_gizmo:
		drag_gizmo(new_pos)
		adjust_gizmos_for_resize()
		transform_selected_overlay()
		
	elif translating:
		translation_gizmo.global_position = new_pos
		transform_selected_overlay()
		reposition_gizmos()
	
	emit_signal("overlay_resized", translation_gizmo.size)
	emit_signal("overlay_translated", translation_gizmo.global_position)


func start_resize(gizmo_idx : int) -> void:
	dragging_gizmo = resize_gizmos[gizmo_idx]
	clicked_offset = dragging_gizmo.position - mouse_pos
	
	if gizmo_idx in [0, 1, 2]:
		v_following.append(resize_gizmos[0])
		v_following.append(resize_gizmos[1])
		v_following.append(resize_gizmos[2])
	elif gizmo_idx in [4, 5, 6]:
		v_following.append(resize_gizmos[4])
		v_following.append(resize_gizmos[5])
		v_following.append(resize_gizmos[6])
	
	if gizmo_idx in [2, 3, 4]:
		h_following.append(resize_gizmos[2])
		h_following.append(resize_gizmos[3])
		h_following.append(resize_gizmos[4])
	elif gizmo_idx in [6, 7, 0]:
		h_following.append(resize_gizmos[6])
		h_following.append(resize_gizmos[7])
		h_following.append(resize_gizmos[0])


func stop_resize() -> void:
	dragging_gizmo = null
	
	v_following.clear()
	h_following.clear()


func start_translate() -> void:
	clicked_offset = selected_overlay.global_position - mouse_pos
	translating = true


func stop_translate() -> void:
	translating = false


func transform_selected_overlay() -> void:
	selected_overlay.global_position = translation_gizmo.global_position
	selected_overlay.size = translation_gizmo.size


# Gizmos
func reposition_gizmos() -> void:
	resize_gizmos[0].global_position = selected_overlay.global_position + Vector2(-10, -10)
	resize_gizmos[2].global_position = selected_overlay.global_position + Vector2(selected_overlay.size.x, -10)
	resize_gizmos[4].global_position = selected_overlay.global_position + selected_overlay.size
	resize_gizmos[6].global_position = selected_overlay.global_position + Vector2(-10, selected_overlay.size.y)
	
	resize_gizmos[1].global_position.x = .5 * (resize_gizmos[0].global_position.x + resize_gizmos[2].global_position.x)
	resize_gizmos[1].global_position.y = resize_gizmos[0].global_position.y
	
	resize_gizmos[3].global_position.y = .5 * (resize_gizmos[2].global_position.y + resize_gizmos[4].global_position.y)
	resize_gizmos[3].global_position.x = resize_gizmos[2].global_position.x
	
	resize_gizmos[5].global_position.x = .5 * (resize_gizmos[4].global_position.x + resize_gizmos[6].global_position.x)
	resize_gizmos[5].global_position.y = resize_gizmos[4].global_position.y
	
	resize_gizmos[7].global_position.y = .5 * (resize_gizmos[6].global_position.y + resize_gizmos[0].global_position.y)
	resize_gizmos[7].global_position.x = resize_gizmos[6].global_position.x
	
	translation_gizmo.global_position = selected_overlay.global_position
	translation_gizmo.size = selected_overlay.size


func adjust_gizmos_for_resize() -> void:
	# Resize
	for i in range(h_following.size()):
		h_following[i].global_position.x = dragging_gizmo.global_position.x

	if h_following.size() > 0:
		resize_gizmos[1].global_position.x = .5 * (resize_gizmos[0].global_position.x + resize_gizmos[2].global_position.x)
		resize_gizmos[5].global_position.x = .5 * (resize_gizmos[6].global_position.x + resize_gizmos[4].global_position.x)

	for i in range(v_following.size()):
		v_following[i].global_position.y = dragging_gizmo.global_position.y

	if v_following.size() > 0:
		resize_gizmos[3].global_position.y = .5 * (resize_gizmos[2].global_position.y + resize_gizmos[4].global_position.y)
		resize_gizmos[7].global_position.y = .5 * (resize_gizmos[0].global_position.y + resize_gizmos[6].global_position.y)

	# Translation
	var lowest_point : Control

	for gizmo in resize_gizmos:
		if lowest_point == null or lowest_point.position.x > gizmo.position.x or lowest_point.position.y > gizmo.position.y:
			lowest_point = gizmo

	translation_gizmo.global_position = lowest_point.global_position + Vector2(10, 10)

	translation_gizmo.size.x = abs(resize_gizmos[0].position.x - resize_gizmos[2].position.x) - 10
	translation_gizmo.size.y = abs(resize_gizmos[0].position.y - resize_gizmos[6].position.y) - 10


func drag_gizmo(pos : Vector2) -> void:
	var top  : bool = dragging_gizmo == resize_gizmos[0] or dragging_gizmo == resize_gizmos[1] or dragging_gizmo == resize_gizmos[2]
	var left : bool = dragging_gizmo == resize_gizmos[6] or dragging_gizmo == resize_gizmos[7] or dragging_gizmo == resize_gizmos[0]
	
	# Adjust grid top and left for gizmo offset
	if grid.is_visible:
		if top: 
			pos.y -= 10
	
		if left:
			pos.x -= 10
	
	if dragging_gizmo == resize_gizmos[3] or dragging_gizmo == resize_gizmos[7]:
		dragging_gizmo.global_position.x = pos.x
	elif dragging_gizmo == resize_gizmos[1] or dragging_gizmo == resize_gizmos[5]:
		dragging_gizmo.global_position.y = pos.y
	else:
		dragging_gizmo.global_position = pos


func is_mouse_hovering_interface() -> bool:
	if !Input.is_action_pressed("alt"):
		for interface in selection_stoppers:
			if interface.get_global_rect().has_point(mouse_pos):
				return true
	return false
