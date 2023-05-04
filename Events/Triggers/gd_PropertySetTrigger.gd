class_name PropertySetTrigger
extends Trigger

enum Mode { ANY, LESS, MORE }
@export var mode : Mode = Mode.ANY
@export var equal := false

@export var property : Property
@export var value_container : VariantDataContainer

signal property_nulled()


func _init():
	type = Type.PROPERTY


func reset(overlay : Overlay):
	property.find_equivalent_property(overlay)


func match_properties(overlay : Overlay) -> void:
	var prop = property.find_equivalent_property(overlay)
	set_property(prop, true)
	
	if value_container.current_data_type == TYPE_OBJECT:
		var matched_value = value_container.get_property().find_equivalent_property(overlay)
		value_container.set_property(matched_value)


func check_for_trigger():
	if value_container.get_value() == null:
		return
	
	match mode:
		Mode.ANY:
			if equal:
				if property.get_value() == value_container.get_value():
					trigger()
			else:
				trigger()
		
		Mode.LESS:
			if equal:
				if property.get_value() <= value_container.get_value():
					trigger()
			elif property.get_value() < value_container.get_value():
				trigger()
		
		Mode.MORE:
			if equal:
				if property.get_value() >= value_container.get_value():
					trigger()
			elif property.get_value() > value_container.get_value():
				trigger()


func process_settings(id : int) -> void:
	match id:
		0:
			set_mode(Mode.ANY)
		1:
			set_mode(Mode.LESS)
		2:
			set_mode(Mode.MORE)
		4:
			toggle_equal()


func toggle_equal():
	equal = !equal


func set_mode(new_mode : Mode):
	mode = new_mode


func set_property(new_property : Property, suppress_fill_in := false):
	if property and property.is_connected("property_set", Callable(self, "check_for_trigger")):
		property.disconnect("property_set", Callable(self, "check_for_trigger"))
	
	property = new_property
	
	if property:
		if value_container.get_property() and value_container.get_property().type != property.type:
			value_container.set_property(null)
			property_nulled.emit()
		elif !suppress_fill_in:
			set_value(new_property.get_value())
		
		property.connect("property_set", Callable(self, "check_for_trigger"))


func toggle_property(using_property : bool):
	if using_property:
		value_container.current_data_type = TYPE_OBJECT
	elif property:
		value_container.current_data_type = property.type


func set_value(new_value):
	if typeof(new_value) == TYPE_OBJECT:
		value_container.set_property(new_value)
		return
	
	value_container.set_value(new_value)
