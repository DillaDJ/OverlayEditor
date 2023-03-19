class_name Overlay
extends Control


var overridable_properties 	: Array[Property] = []
var attached_events 		: Array[Event] = []

signal name_changed(new_name)
signal transformed()


func _ready():
	overridable_properties.append(ReadProperty.new("Name", 		Property.Type.STRING_SHORT, Callable(self, "get_name"), Callable(self, "set_overlay_name")))
	overridable_properties.append(ReadProperty.new("Position", 	Property.Type.VECTOR2, Callable(self, "get_position"), Callable(self, "set_overlay_pos")))
	overridable_properties.append(ReadProperty.new("Size", 		Property.Type.VECTOR2, Callable(self, "get_size"), Callable(self, "set_overlay_size")))


func set_overlay_name(new_name):
	set_name(new_name)
	emit_signal("name_changed", new_name)


func set_overlay_pos(new_pos):
	set_position(new_pos)
	emit_signal("transformed")


func set_overlay_size(new_size):
	set_size(new_size)
	emit_signal("transformed")
