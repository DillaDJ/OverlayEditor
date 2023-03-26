class_name Property

enum Type { ENUM, BOOL, INT, FLOAT, STRING_SHORT, STRING, VECTOR2, VECTOR4, COLOR, TEXTURE }
var type : Type

var prop_name : String

var getter : Callable

var hidden : bool


func _init(new_name : String, new_type : Type, new_getter : Callable, is_hidden : bool = false):
	prop_name = new_name
	type = new_type
	getter = new_getter
	hidden = is_hidden


func find_equivalent_property(overlay : Overlay) -> Property:
	for property in overlay.overridable_properties:
		if property.prop_name == prop_name:
			return property
	
	for event in overlay.attached_events:
		for property in event.properties:
			if property.prop_name == prop_name:
				return property
	
	return null


func get_property():
	return getter.call()
