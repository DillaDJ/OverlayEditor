class_name Property

enum Type { NONE, ENUM, BOOL, INT, FLOAT, STRING_SHORT, STRING, VECTOR2, VECTOR4, COLOR, TEXTURE }
var type : Type

var prop_name : String
var prop_path : String

var getter : Callable

var hidden : bool


func _init(new_name : String, new_type : Type, new_getter : Callable, is_hidden : bool = false):
	prop_name = new_name
	type = new_type
	getter = new_getter
	hidden = is_hidden


func get_property():
	return getter.call()


func find_equivalent_property(overlay : Overlay) -> Property:
	var property_container = overlay if prop_path == "" or prop_path == "." else overlay.get_node(prop_path)
	
	if property_container:
		for property in property_container.overridable_properties:
			if property.prop_name == prop_name:
				return property
		
		for event in property_container.attached_events:
			for property in event.properties:
				if property.prop_name == prop_name:
					return property
	
	return null


func get_display_name() -> String:
	if prop_path == "" or prop_path == ".":
		return prop_name 
	else:
		return "%s/%s" % [prop_path, prop_name]
	
