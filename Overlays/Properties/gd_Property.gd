class_name Property

enum Type { ENUM, BOOL, INT, FLOAT, STRING_SHORT, STRING, VECTOR2, VECTOR4, COLOR, TEXTURE }
var type : Type

var prop_name : String

var getter : Callable


func _init(new_name : String, new_type : Type, new_getter : Callable):
	prop_name = new_name
	type = new_type
	getter = new_getter


func get_property():
	return getter.call()
