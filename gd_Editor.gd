class_name Editor
extends Node


enum EditingTools { MOVE }

#@onready var move_tool : MoveTool = %MoveTool

#signal tool_changed(tool_type : EditingTools)
signal overlay_created(overlay)


#func select_tool(tool_type : EditingTools) -> void:
#	emit_signal("tool_changed", tool_type)
