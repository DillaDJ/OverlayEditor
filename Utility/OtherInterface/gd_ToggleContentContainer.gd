class_name ToggleContentContainer
extends Control

enum DockedEdge { LEFT, TOP, RIGHT, BOTTOM }
enum ToggleType { CLICK, HOVER }

@onready var anim_player : AnimationPlayer = $AnimationPlayer

@export var docked_edge : DockedEdge
@export var toggle_type : ToggleType

@export var unhover_hider : Button

@export var hide_toggle_button := false

@export var extra_move_offset := 0

var anim_lib  : AnimationLibrary

var hovering_content := false
var toggled := false
var move_width := 0


func _ready():
	if hide_toggle_button:
		var toggle_button : Button = $ToggleShow 
		toggle_button.text = ""
		toggle_button.flat = true
	
	if docked_edge == DockedEdge.LEFT or docked_edge == DockedEdge.RIGHT:
		move_width = get_child(2).size.x + extra_move_offset
	else:
		move_width = get_child(2).size.y + extra_move_offset
	
	setup_params()
	setup_animations()


func setup_params():
	var toggle_button : Button = $ToggleShow
	
	if toggle_type == ToggleType.CLICK:
		toggle_button.connect("button_down", Callable(self, "click_toggle_show_mode"))
	
	elif toggle_type == ToggleType.HOVER:
		toggle_button.connect("mouse_entered", Callable(self, "hover_show_mode"))
		
		if unhover_hider:
			unhover_hider.connect("mouse_exited", Callable(self, "hover_hide_mode"))
		else:
			toggle_button.connect("mouse_exited", Callable(self, "hover_hide_mode"))
		
		anim_player.connect("animation_finished", Callable(self, "reset_lock"))


func setup_animations():
	get_viewport().connect("size_changed", Callable(self, "adjust_anim_clips"))
	
	anim_lib = AnimationLibrary.new()
	
	var unfold_anim := Animation.new()
	var fold_anim  	:= Animation.new()
	
	unfold_anim.add_track(Animation.TYPE_VALUE, 0)
	unfold_anim.track_set_path(0, ":position")
	
	fold_anim.add_track(Animation.TYPE_VALUE, 0)
	fold_anim.track_set_path(0, ":position")
	
	if docked_edge == DockedEdge.RIGHT:
		var res_width := get_viewport_rect().size.x
		
		unfold_anim.track_insert_key(0, 0,  Vector2(res_width, position.y))
		unfold_anim.track_insert_key(0, .8, Vector2(res_width - move_width, position.y))
		unfold_anim.track_set_key_transition(0, 0, .35)
	
		fold_anim.track_insert_key(0, 0,  Vector2(res_width - move_width, position.y))
		fold_anim.track_insert_key(0, .8, Vector2(res_width, position.y))
		fold_anim.track_set_key_transition(0, 0, .35)
		
	elif docked_edge == DockedEdge.LEFT:
		unfold_anim.track_insert_key(0, 0, Vector2(0, position.y))
		unfold_anim.track_insert_key(0, 0.8, Vector2(move_width, position.y))
		unfold_anim.track_set_key_transition(0, 0, .35)
		
		fold_anim.track_insert_key(0, 0,  Vector2(move_width, position.y))
		fold_anim.track_insert_key(0, .8, Vector2(0, position.y))
		fold_anim.track_set_key_transition(0, 0, .35)
	
	elif docked_edge == DockedEdge.TOP:
		unfold_anim.track_insert_key(0, 0, Vector2(position.x, 0))
		unfold_anim.track_insert_key(0, 0.8, Vector2(position.x, move_width))
		unfold_anim.track_set_key_transition(0, 0, .35)
		
		fold_anim.track_insert_key(0, 0,  Vector2(position.x, move_width))
		fold_anim.track_insert_key(0, .8, Vector2(position.x, 0))
		fold_anim.track_set_key_transition(0, 0, .35)
	
	anim_lib.add_animation("unfold", unfold_anim)
	anim_lib.add_animation("fold", 	 fold_anim)
	
	anim_player.add_animation_library("toggles", anim_lib)


func click_toggle_show_mode():	
	if !toggled:
		anim_player.play("toggles/unfold")
		toggled = true
	else:
		anim_player.play("toggles/fold")
		toggled = false


func hover_show_mode():
	if !toggled:
		anim_player.play("toggles/unfold")
		toggled = true


func hover_hide_mode():
	anim_player.play("toggles/fold")


func adjust_anim_clips():
	var unfold_anim := anim_lib.get_animation("unfold")
	var fold_anim 	:= anim_lib.get_animation("fold")
	
	if docked_edge == DockedEdge.RIGHT:
		var res_width := get_viewport_rect().size.x

		unfold_anim.track_set_key_value(0, 0, Vector2(res_width, position.y))
		unfold_anim.track_set_key_value(0, 1, Vector2(res_width - move_width, position.y))

		fold_anim.track_set_key_value(0, 0, Vector2(res_width - move_width, position.y))
		fold_anim.track_set_key_value(0, 1, Vector2(res_width, position.y))


func reset_lock(anim_name):
	if anim_name == "toggles/fold":
		toggled = false


func toggle_content_hover(value : bool):
	hovering_content = value
