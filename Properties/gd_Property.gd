class_name Property
extends Resource

# TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING, TYPE_STRING_NAME (long string), TYPE_VECTOR2, 
# TYPE_VECTOR4, TYPE_COLOR, TYPE_PROJECTION (texture), TYPE_PACKED_INT32_ARRAY (enum)
var type : Variant.Type
var write := false

@export var prop_name : String
@export var prop_path : String

var hidden_prop : bool = false

var getter : Callable
var setter : Callable


signal property_set()


# Creation and setup - All propety create functions create properties to an array, they do not return properties!
# This is for splitting vector properties and making creating properties in code cleaner
static func create_read(property_array : Array[Property], p_name : String, prop_type : Variant.Type, p_getter : Callable, prop_hidden = false):
	var property := Property.new()
	property.setup(p_name, prop_type, p_getter, prop_hidden)
	
	property_array.append(property)
	
	if prop_type == TYPE_VECTOR2 or prop_type == TYPE_VECTOR4:
		var split_axis = VectorSplitProperty.split_vector(property, true)
		for axis in split_axis:
			property_array.append(axis)


static func create_write(property_array : Array[Property], p_name : String, prop_type : Variant.Type, p_getter : Callable, p_setter : Callable, prop_hidden = false):
	var property := Property.new()
	property.setup_write(p_name, prop_type, p_getter, p_setter, prop_hidden)
	property_array.append(property)
	
	if prop_type == TYPE_VECTOR2 or prop_type == TYPE_VECTOR4:
		var split_axis = VectorSplitProperty.split_vector(property, true)
		for axis in split_axis:
			property_array.append(axis)
			axis.write = true


func setup_write(new_name : String, new_type : Variant.Type, new_getter : Callable, new_setter : Callable, is_hidden : bool = false):
	setup(new_name, new_type, new_getter, is_hidden)
	setter = new_setter
	write = true


func setup(new_name : String, new_type : Variant.Type, new_getter : Callable, is_hidden : bool = false):
	prop_name = new_name
	type = new_type
	getter = new_getter
	hidden_prop = is_hidden


# Getter and setter
func get_value():
	return getter.call()


func set_value(new_value) -> void:
	if !write:
		printerr("Property: %s is read only" % prop_name)
		return
	
	setter.call(new_value)
	property_set.emit()


func get_display_name() -> String:
	if prop_path == "" or prop_path == ".":
		return prop_name 
	else:
		return "%s/%s" % [prop_path, prop_name]


# Util
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
