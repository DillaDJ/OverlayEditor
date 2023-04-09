class_name EnumProperty
extends Property


@export var types : Array[String]


static func create_enum(property_array : Array[Property], p_name : String, type_array : Array[String], p_getter : Callable, p_setter : Callable, prop_hidden = false):
	var property := EnumProperty.new()
	property.setup_enum(p_name, type_array, p_getter, p_setter, prop_hidden)
	property_array.append(property)


func setup_enum(new_name : String, types_array : Array[String], new_getter : Callable, new_setter : Callable, is_hidden : bool = false):
	setup_write(new_name, TYPE_PACKED_INT32_ARRAY, new_getter, new_setter, is_hidden)
	types = types_array
