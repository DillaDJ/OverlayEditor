class_name  MoveTool
extends EditingTool


@onready var grid : OverlayGrid = %Grid
@onready var translation_gizmo = $TranslationGizmo

# Resize gizmo order
# 0 1 2
# 7 * 3
# 6 5 4
@onready var resize_gizmos = $ResizeGizmos.get_children()

var selected_overlay : Control

var dragging_gizmo : Control
var mouse_pos

# Gizmos that are following another gizmo as a result of moving it
var h_following : Array[Control] = []
var v_following : Array[Control] = []

var translating  := false

var clicked_offset : Vector2

var click_time = 0
var click_time_threshold = 0.2


signal overlay_selected(overlay)
signal overlay_deselected()


func _ready():
	super._ready()
	
	var resize_gizmo_nodes = $ResizeGizmos.get_children()
	for i in range(resize_gizmo_nodes.size()):
		resize_gizmo_nodes[i].connect("button_down", Callable(self, "start_resize").bind(i))
		resize_gizmo_nodes[i].connect("button_up", Callable(self, "stop_resize"))
	
	translation_gizmo.connect("button_down", Callable(self, "start_translate"))
	translation_gizmo.connect("button_up", Callable(self, "stop_translate"))
	
	%Hierarchy.connect("item_selected", Callable(self, "select_from_idx"))
	%Hierarchy.connect("child_selected", Callable(self, "select_child_from_idx"))
	%Hierarchy.connect("items_deselected", Callable(self, "deselect_overlay"))


func _unhandled_input(event):
	if Input.is_action_pressed("left_click"):
		deselect_overlay()


func _process(delta):
	if enabled:
		mouse_pos = get_viewport().get_mouse_position()
		
		if Input.is_action_pressed("left_click"):
			translate_and_resize()
			click_time += delta
		
		if Input.is_action_just_released("left_click"):
			if click_time < click_time_threshold:
				check_for_selections()
			
			click_time = 0


func change_tool(tool_type : Editor.EditingTools):
	enabled = tool_type == Editor.EditingTools.MOVE
	
	if selected_overlay:
		show()


# Selection
func check_for_selections():
	var selection_group = []
	var overlays = %OverlayElements.get_children()
	overlays.reverse()
	
	for overlay in overlays:
		if overlay.get_global_rect().has_point(mouse_pos):
			selection_group.append(overlay)
			
			for child in overlay.get_children():
				if child.get_global_rect().has_point(mouse_pos):
					selection_group.append(child)
	
	if selection_group.size() > 0:
		var selected_idx : int = selection_group.find(selected_overlay)
		if selected_idx != -1:
			var new_selection = selection_group[(selected_idx + 1) % selection_group.size()]
			if new_selection == selected_overlay:
				return
			
			click_select_overlay(new_selection)
		else:
			click_select_overlay(selection_group[0])


func click_select_overlay(overlay):
	select_overlay(overlay)
	emit_signal("overlay_selected", overlay)


func select_overlay(overlay):
	selected_overlay = overlay
	
	reposition_gizmos()
	
	translation_gizmo.global_position = overlay.global_position
	translation_gizmo.size = overlay.size
	
	if enabled:
		show()


func deselect_overlay():
	selected_overlay = null
	emit_signal("overlay_deselected")
	hide()


func select_from_idx(idx):
	var overlay = %OverlayElements.get_children()[idx]
	select_overlay(overlay)


func select_child_from_idx(parent_idx, child_idx):
	var parent = %OverlayElements.get_children()[parent_idx]
	var child = parent.get_child(child_idx)
	select_overlay(child)


# Resize and translate
func translate_and_resize():
	var new_pos = mouse_pos + clicked_offset
	
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


func start_resize(pos_idx):
	dragging_gizmo = resize_gizmos[pos_idx]
	clicked_offset = dragging_gizmo.position - mouse_pos
	
	if pos_idx in [0, 1, 2]:
		v_following.append(resize_gizmos[0])
		v_following.append(resize_gizmos[1])
		v_following.append(resize_gizmos[2])
	elif pos_idx in [4, 5, 6]:
		v_following.append(resize_gizmos[4])
		v_following.append(resize_gizmos[5])
		v_following.append(resize_gizmos[6])
	
	if pos_idx in [2, 3, 4]:
		h_following.append(resize_gizmos[2])
		h_following.append(resize_gizmos[3])
		h_following.append(resize_gizmos[4])
	elif pos_idx in [6, 7, 0]:
		h_following.append(resize_gizmos[6])
		h_following.append(resize_gizmos[7])
		h_following.append(resize_gizmos[0])


func stop_resize():
	dragging_gizmo = null
	
	v_following.clear()
	h_following.clear()


func start_translate():
	clicked_offset = selected_overlay.global_position - mouse_pos
	translating = true


func stop_translate():
	translating = false


func transform_selected_overlay():
	selected_overlay.global_position = translation_gizmo.global_position
	selected_overlay.size = translation_gizmo.size


# Gizmos
func reposition_gizmos():
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


func adjust_gizmos_for_resize():
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


func drag_gizmo(pos):
	var top  : bool = dragging_gizmo == resize_gizmos[0] or dragging_gizmo == resize_gizmos[1] or dragging_gizmo == resize_gizmos[2]
	var left : bool = dragging_gizmo == resize_gizmos[6] or dragging_gizmo == resize_gizmos[7] or dragging_gizmo == resize_gizmos[0]
	
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
