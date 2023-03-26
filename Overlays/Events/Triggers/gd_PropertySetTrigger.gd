class_name PropertySetTrigger
extends Trigger


var property : WriteProperty

var specific_value := false
var value


func _init():
	type = Type.PROPERTY_SET


func duplicate(overlay : Overlay) -> Trigger:
	var duplicated_trigger = PropertySetTrigger.new()
	if specific_value:
		duplicated_trigger.toggle_specific_value()
		duplicated_trigger.change_value(value)
	
	if property:
		var matching_property = property.find_equivalent_property(overlay)
		duplicated_trigger.change_property(matching_property)
	
	return duplicated_trigger


func change_property(new_property : Property):
	if property and property.is_connected("property_set", Callable(self, "execute")):
		property.disconnect("property_set", Callable(self, "execute"))
	
	property = new_property
	
	if new_property:
		property.connect("property_set", Callable(self, "check_for_trigger"))


func check_for_trigger():
	if specific_value:
		var value_to_check = value if typeof(value) != TYPE_OBJECT else value.get_property()
		
		if property.get_property() == value_to_check:
			trigger()
	else:
		trigger()


func toggle_specific_value():
	specific_value = !specific_value


func change_value(new_value):
	value = new_value
