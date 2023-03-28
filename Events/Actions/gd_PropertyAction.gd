class_name PropertyAction
extends Action


enum Mode { SET, ADD, SUBTRACT }
var mode : Mode = Mode.SET

var property : Property
var value

signal value_nulled()


func _init():
	type = Type.PROPERTY


func duplicate() -> Action:
	var duplicated_action = PropertyAction.new()
	
	duplicated_action.property = property
	duplicated_action.value = value
	duplicated_action.mode = mode
	
	return duplicated_action


func match_properties(overlay : Overlay) -> void:
	var prop = property.find_equivalent_property(overlay)
	property = prop
	
	if prop:
		if typeof(value) == TYPE_OBJECT:
			var matched_value = value.find_equivalent_property(overlay)
			value = matched_value


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
	if typeof(value) == TYPE_OBJECT and value.type != new_property.type:
		value = null
		value_nulled.emit()
	
	property = new_property


func change_value(new_value):
	value = new_value
