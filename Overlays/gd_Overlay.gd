class_name Overlay
extends Control


var overridable_properties 	: Array = []
var attached_events 		: Array = []

signal name_changed(new_name)
signal transformed()


func _ready():
	overridable_properties.append(Property.new("Name", 		Property.Type.STRING_SHORT, Callable(self, "get_name"), Callable(self, "set_overlay_name")))
	overridable_properties.append(Property.new("Position", 	Property.Type.VECTOR2, Callable(self, "get_position"), Callable(self, "set_overlay_pos")))
	overridable_properties.append(Property.new("Size", 		Property.Type.VECTOR2, Callable(self, "get_size"), Callable(self, "set_overlay_size")))
	overridable_properties.append("SPACE")


func set_overlay_name(new_name):
	set_name(new_name)
	emit_signal("name_changed", new_name)


func set_overlay_pos(new_pos):
	set_position(new_pos)
	emit_signal("transformed")


func set_overlay_size(new_size):
	set_size(new_size)
	emit_signal("transformed")
