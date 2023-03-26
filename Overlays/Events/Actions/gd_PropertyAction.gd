class_name PropertyAction
extends Action


enum Mode { SET, ADD, SUBTRACT }
var mode : Mode = Mode.SET

var property : Property
var value


func _init():
	type = Type.PROPERTY


func duplicate(overlay) -> Action:
	var duplicated_action = PropertyAction.new()
	
	if property:		
		var matching_property = property.find_equivalent_property(overlay)
		duplicated_action.change_property(matching_property)
		duplicated_action.change_value(value)
	duplicated_action.change_mode(mode)
	
	return duplicated_action


func execute():
	if property == null or value == null:
		return
	
	var new_value
	if typeof(value) == TYPE_OBJECT:
		match mode:
			Mode.SET:
				new_value = value.get_property()

			Mode.ADD:
				new_value = value.get_property() + property.get_property()

			Mode.SUBTRACT:
				new_value = value.get_property() - property.get_property()
	else:
		match mode:
			Mode.SET:
				new_value = value

			Mode.ADD:
				new_value = value + property.get_property()

			Mode.SUBTRACT:
				new_value = value - property.get_property()

	property.set_property(new_value)


func change_mode(new_mode : Mode) -> void:
	mode = new_mode


func change_property(new_property : Property) -> void:
	property = new_property


func change_value(new_value):
	value = new_value
