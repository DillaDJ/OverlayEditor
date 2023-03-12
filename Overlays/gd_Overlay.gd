class_name Overlay
extends Control


class Property: 
	enum Type { INT, FLOAT, STRING_SHORT, STRING, VECTOR2, VECTOR4, COLOR }
	var type : Type
	
	var prop_name : String
	
	var overlay_getter : Callable
	var overlay_setter : Callable
	
	
	func _init(new_name, new_type, new_getter, new_setter):
		prop_name = new_name
		type = new_type
		overlay_getter = new_getter
		overlay_setter = new_setter
	
	
	func get_property():
		return overlay_getter.call()
	
	
	func apply_property(new_value):
		overlay_setter.call(new_value)


var overridable_properties : Array = []


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
