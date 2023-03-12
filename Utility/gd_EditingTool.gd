#class_name EditingTool
#extends Control


#var enabled := false


#func _ready():
#	sngl_Utility.get_scene_root().connect("tool_changed", Callable(self, "change_tool"))
