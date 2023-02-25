class_name Editor
extends Node

enum EditingTools { MOVE, SELECT }

@onready var move_tool : MoveTool = %MoveTool

var selected_tool_type : EditingTools


func _process(_delta):
	process_selected_tool()


func process_selected_tool():
	match selected_tool_type:
		EditingTools.MOVE:
			
			if Input.is_action_just_pressed("left_click") and !move_tool.selected_overlay:
				var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		
				for overlay in %OverlayElements.get_children():
					if overlay.get_global_rect().has_point(mouse_pos):
						move_tool.select_overlay(overlay)
			
			move_tool.process_tool()
		
		EditingTools.SELECT:
			pass


func select_tool(tool_type):
	selected_tool_type = tool_type
