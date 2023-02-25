class_name  MoveTool
extends Control


@onready var grid : Grid = %Grid
@onready var translation_gizmo = $TranslationGizmo

# Resize gizmo order
# 0 1 2
# 7 * 3
# 6 5 4
@onready var resize_gizmos = $ResizeGizmos.get_children()

var selected_overlay : Control
var dragging_gizmo : Control

# Gizmos that are following another gizmo as a result of moving it
var h_following : Array[Control] = []
var v_following : Array[Control] = []

var translating := false


func _ready():
	var resize_gizmo_nodes = $ResizeGizmos.get_children()
	for i in range(resize_gizmo_nodes.size()):
		resize_gizmo_nodes[i].connect("button_down", Callable(self, "start_resize").bind(i))
		resize_gizmo_nodes[i].connect("button_up", Callable(self, "stop_resize"))
	
	translation_gizmo.connect("button_down", Callable(self, "start_translate"))
	translation_gizmo.connect("button_up", Callable(self, "stop_translate"))


func _process(_delta):
	if Input.is_action_just_pressed("escape"):
		deselect_overlay()


func process_tool():
	if dragging_gizmo or translating:
		var mouse_pos = get_viewport().get_mouse_position()
		
		if  grid.is_visible_in_tree():
			mouse_pos = grid.snap_to_nearest_point(mouse_pos)
		
		if dragging_gizmo:
			if dragging_gizmo == resize_gizmos[0] or dragging_gizmo == resize_gizmos[1] or dragging_gizmo == resize_gizmos[2]:
				mouse_pos.y -= 10
			
			if dragging_gizmo == resize_gizmos[0] or dragging_gizmo == resize_gizmos[6] or dragging_gizmo == resize_gizmos[7]:
				mouse_pos.x -= 10
			
			if dragging_gizmo == resize_gizmos[3] or dragging_gizmo == resize_gizmos[7]:
				dragging_gizmo.global_position.x = mouse_pos.x
			elif dragging_gizmo == resize_gizmos[1] or dragging_gizmo == resize_gizmos[5]:
				dragging_gizmo.global_position.y = mouse_pos.y
			else:
				dragging_gizmo.global_position = mouse_pos
			
			reposition_gizmos_after_resize()
			transform_selected_overlay()
		
		elif translating:
			translation_gizmo.position = mouse_pos
			transform_selected_overlay()
			reposition_gizmos()


func select_overlay(overlay):
	selected_overlay = overlay
	
	reposition_gizmos()
	
	translation_gizmo.position = overlay.position
	translation_gizmo.size = overlay.size
	
	show()


func deselect_overlay():
	selected_overlay = null	
	hide()


func start_resize(pos_idx):
	dragging_gizmo = resize_gizmos[pos_idx]
	
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


func reposition_gizmos_after_resize():
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

	translation_gizmo.position = lowest_point.position + Vector2(10, 10)

	translation_gizmo.size.x = abs(resize_gizmos[0].position.x - resize_gizmos[2].position.x) - 10
	translation_gizmo.size.y = abs(resize_gizmos[0].position.y - resize_gizmos[6].position.y) - 10


func transform_selected_overlay():
	selected_overlay.global_position = translation_gizmo.global_position
	selected_overlay.size = translation_gizmo.size


func start_translate():
	translating = true


func stop_translate():
	translating = false
