class_name ReadProperty
extends  Property


var setter : Callable


func _init(new_name : String, new_type : Type, new_getter : Callable, new_setter : Callable):
	super(new_name, new_type, new_getter)
	setter = new_setter


func set_property(new_value) -> void:
	setter.call(new_value)


class EnumProperty extends ReadProperty:
	var types : Array[String]
	
	func _init(new_name : String, types_array : Array[String], new_getter : Callable, new_setter : Callable):
		prop_name = new_name
		type = Type.ENUM
		types = types_array
		getter = new_getter
		setter = new_setter
