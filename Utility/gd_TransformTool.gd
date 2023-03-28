class_name TransformTool
extends Control


# Resize gizmo order
# 0 1 2
# 7 * 3
# 6 5 4
@onready var resizing_gizmos : Array[Node] = $ResizeGizmos.get_children()
@onready var translation_gizmo : Button = $TranslationGizmo
@onready var grid : OverlayGrid = %Grid

const gizmo_offset := 10

var enabled := true

var dragging_gizmo : Control
var transforming_overlay : Overlay

# Gizmos that are following another gizmo as a result of moving it
var h_following : Array[Control] = []
var v_following : Array[Control] = []

var clicked_offset : Vector2

var translating 	:= false
var just_selected 	:= false

signal overlay_translated(overlay_position : Vector2)
signal overlay_resized(overlay_size : Vector2)


func _ready() -> void:
	var editor : Editor = sngl_Utility.get_scene_root()
	
	editor.connect("overlay_selected", Callable(self, "set_transforming_overlay"))
	editor.connect("overlay_deselected", Callable(self, "unset_transforming_overlay"))
	editor.connect("overlay_hierarchy_selected", Callable(self, "become_just_selected"))
	
	for i in range(resizing_gizmos.size()):
		resizing_gizmos[i].connect("button_down", Callable(self, "start_resize").bind(i))
		resizing_gizmos[i].connect("button_up", Callable(self, "stop_resize"))
	
	translation_gizmo.connect("button_down", Callable(self, "start_translate"))
	translation_gizmo.connect("button_up", Callable(self, "stop_translate"))


func _process(_delta : float) -> void:
	# Skip a frame so that properties don't get applied to hierarchy selects before registering that a new overlay was selected
	if just_selected:
		just_selected = false
		return
	
	if enabled and transforming_overlay and (translating or dragging_gizmo):
		var new_pos : Vector2 = get_viewport().get_mouse_position() + clicked_offset
		
		if grid.is_visible:
			new_pos = grid.snap_to_nearest_point(new_pos)
		
		if translating:
			translate(new_pos)
		elif dragging_gizmo:
			resize(new_pos)


func toggle_enabled() -> void:
	enabled = !enabled


func set_transforming_overlay(overlay : Overlay) -> void:
	var pos_prop : Property = overlay.find_property("Position")
	var size_prop : Property = overlay.find_property("Size")
	
	if pos_prop and !pos_prop.is_connected("property_set", Callable(self, "recenter_gizmos")):
		pos_prop.connect("property_set", Callable(self, "recenter_gizmos"))
	if size_prop and !size_prop.is_connected("property_set", Callable(self, "recenter_gizmos")):
		size_prop.connect("property_set", Callable(self, "recenter_gizmos"))
	
	transforming_overlay = overlay
	recenter_gizmos()
	show()


func unset_transforming_overlay() -> void:
	var pos_prop : Property = transforming_overlay.find_property("Position")
	var size_prop : Property = transforming_overlay.find_property("Size")
	
	if pos_prop and pos_prop.is_connected("property_set", Callable(self, "recenter_gizmos")):
		pos_prop.disconnect("property_set", Callable(self, "recenter_gizmos"))
	if size_prop and size_prop.is_connected("property_set", Callable(self, "recenter_gizmos")):
		size_prop.disconnect("property_set", Callable(self, "recenter_gizmos"))
	
	transforming_overlay = null
	hide()


func become_just_selected(_overlay : Overlay) -> void:
	just_selected = true


# Transformation
func start_translate() -> void:
	clicked_offset = transforming_overlay.global_position - get_viewport().get_mouse_position()
	translating = true


func stop_translate() -> void:
	translating = false


func translate(pos : Vector2) -> void:
	translation_gizmo.global_position = pos
	transforming_overlay.global_position = translation_gizmo.global_position
	
	recenter_gizmos()
	
	overlay_translated.emit(translation_gizmo.global_position)


func start_resize(gizmo_idx : int) -> void:
	dragging_gizmo = resizing_gizmos[gizmo_idx]
	clicked_offset = dragging_gizmo.position - get_viewport().get_mouse_position()
	
	if gizmo_idx in [0, 1, 2]:
		v_following.append(resizing_gizmos[0])
		v_following.append(resizing_gizmos[1])
		v_following.append(resizing_gizmos[2])
	elif gizmo_idx in [4, 5, 6]:
		v_following.append(resizing_gizmos[4])
		v_following.append(resizing_gizmos[5])
		v_following.append(resizing_gizmos[6])
	
	if gizmo_idx in [2, 3, 4]:
		h_following.append(resizing_gizmos[2])
		h_following.append(resizing_gizmos[3])
		h_following.append(resizing_gizmos[4])
	elif gizmo_idx in [6, 7, 0]:
		h_following.append(resizing_gizmos[6])
		h_following.append(resizing_gizmos[7])
		h_following.append(resizing_gizmos[0])


func stop_resize() -> void:
	dragging_gizmo = null
	
	v_following.clear()
	h_following.clear()


func resize(pos : Vector2) -> void:
	drag_gizmo(pos)
	resize_gizmos()
	
	transforming_overlay.size = translation_gizmo.size
	
	# Adjust position for resize from top or left
	if resizing_gizmos[1] in v_following or resizing_gizmos[7] in h_following:
		transforming_overlay.global_position = translation_gizmo.global_position
		overlay_translated.emit(translation_gizmo.global_position)
	overlay_resized.emit(translation_gizmo.size)


# Gizmos
func recenter_gizmos() -> void:
	# Position corners around overlay
	resizing_gizmos[0].global_position = transforming_overlay.global_position + Vector2(-gizmo_offset, -gizmo_offset)
	resizing_gizmos[2].global_position = transforming_overlay.global_position + Vector2(transforming_overlay.size.x, -gizmo_offset)
	resizing_gizmos[4].global_position = transforming_overlay.global_position + transforming_overlay.size
	resizing_gizmos[6].global_position = transforming_overlay.global_position + Vector2(-gizmo_offset, transforming_overlay.size.y)
	
	# Interpolate edges
	resizing_gizmos[1].global_position.x = .5 * (resizing_gizmos[0].global_position.x + resizing_gizmos[2].global_position.x)
	resizing_gizmos[1].global_position.y = resizing_gizmos[0].global_position.y
	
	resizing_gizmos[3].global_position.y = .5 * (resizing_gizmos[2].global_position.y + resizing_gizmos[4].global_position.y)
	resizing_gizmos[3].global_position.x = resizing_gizmos[2].global_position.x
	
	resizing_gizmos[5].global_position.x = .5 * (resizing_gizmos[4].global_position.x + resizing_gizmos[6].global_position.x)
	resizing_gizmos[5].global_position.y = resizing_gizmos[4].global_position.y
	
	resizing_gizmos[7].global_position.y = .5 * (resizing_gizmos[6].global_position.y + resizing_gizmos[0].global_position.y)
	resizing_gizmos[7].global_position.x = resizing_gizmos[6].global_position.x
	
	# Recenter transform gizmo
	translation_gizmo.global_position = transforming_overlay.global_position
	translation_gizmo.size = transforming_overlay.size


func resize_gizmos() -> void:
	# Makes gizmos on the same axis follow dragging gizmo and
	# interpolates edge resizing gizmos in intermediate positions
	if h_following.size() > 0:
		for gizmo in h_following:
			gizmo.global_position.x = dragging_gizmo.global_position.x
		
		resizing_gizmos[1].global_position.x = .5 * (resizing_gizmos[0].global_position.x + resizing_gizmos[2].global_position.x)
		resizing_gizmos[5].global_position.x = .5 * (resizing_gizmos[6].global_position.x + resizing_gizmos[4].global_position.x)
	
	if v_following.size() > 0:
		for gizmo in v_following:
			gizmo.global_position.y = dragging_gizmo.global_position.y
		
		resizing_gizmos[3].global_position.y = .5 * (resizing_gizmos[2].global_position.y + resizing_gizmos[4].global_position.y)
		resizing_gizmos[7].global_position.y = .5 * (resizing_gizmos[0].global_position.y + resizing_gizmos[6].global_position.y)

	# Translation Gizmo
	translation_gizmo.global_position = resizing_gizmos[0].global_position + Vector2(gizmo_offset, gizmo_offset)

	translation_gizmo.size.x = abs(resizing_gizmos[0].position.x - resizing_gizmos[2].position.x) - gizmo_offset
	translation_gizmo.size.y = abs(resizing_gizmos[0].position.y - resizing_gizmos[6].position.y) - gizmo_offset


func drag_gizmo(pos : Vector2) -> void:
	# Disallow gizmos getting smaller than min size
	# and adjust grid top and left for gizmo offset
	if resizing_gizmos[1] in v_following:
		var min_pos_y = resizing_gizmos[5].global_position.y - transforming_overlay.custom_minimum_size.y - gizmo_offset
		pos.y = min_pos_y if pos.y > min_pos_y else pos.y
		
		if grid.is_visible:
			pos.y -= gizmo_offset
	elif resizing_gizmos[5] in v_following:
		var min_pos_y = resizing_gizmos[1].global_position.y + transforming_overlay.custom_minimum_size.y + gizmo_offset
		pos.y = min_pos_y if pos.y < min_pos_y else pos.y

	if resizing_gizmos[7] in h_following:
		var min_pos_x = resizing_gizmos[3].global_position.x - transforming_overlay.custom_minimum_size.x - gizmo_offset
		pos.x = min_pos_x if pos.x > min_pos_x else pos.x
		
		if grid.is_visible:
			pos.x -= gizmo_offset
	elif resizing_gizmos[3] in h_following:
		var min_pos_x = resizing_gizmos[7].global_position.x + transforming_overlay.custom_minimum_size.x + gizmo_offset
		pos.x = min_pos_x if pos.x < min_pos_x else pos.x
	
	
	# Only drag certain gizmos
	if dragging_gizmo == resizing_gizmos[3] or dragging_gizmo == resizing_gizmos[7]:
		dragging_gizmo.global_position.x = pos.x
		
	elif dragging_gizmo == resizing_gizmos[1] or dragging_gizmo == resizing_gizmos[5]:
		dragging_gizmo.global_position.y = pos.y

	else:
		dragging_gizmo.global_position = pos

