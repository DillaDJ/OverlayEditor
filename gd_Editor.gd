class_name Editor
extends Node


enum EditingTools { MOVE, MULTI_SELECT }

@onready var move_tool : MoveTool = %MoveTool

signal tool_changed(tool_type : EditingTools)


func select_tool(tool_type):
	emit_signal("tool_changed", tool_type)
