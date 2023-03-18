class_name Property

enum Type { ENUM, BOOL, INT, FLOAT, STRING_SHORT, STRING, VECTOR2, VECTOR4, COLOR, TEXTURE }
var type : Type

var prop_name : String

var overlay_getter : Callable
var overlay_setter : Callable


func _init(new_name : String, new_type : Type, new_getter : Callable, new_setter : Callable):
	prop_name = new_name
	type = new_type
	overlay_getter = new_getter
	overlay_setter = new_setter


func get_property():
	return overlay_getter.call()


func apply_property(new_value) -> void:
	overlay_setter.call(new_value)


class EnumProperty extends Property:
	var types : Array[String]
	
	func _init(new_name : String, types_array : Array[String], new_getter : Callable, new_setter : Callable):
		prop_name = new_name
		type = Type.ENUM
		types = types_array
		overlay_getter = new_getter
		overlay_setter = new_setter
