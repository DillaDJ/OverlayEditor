class_name PropertyAction
extends Action


enum Mode { SET, ADD, SUBTRACT }
var mode : Mode = Mode.SET

var property : Property
var value


func _init():
	type = Type.PROPERTY


func execute():
	if property == null or value == null:
		return
	
	var new_value
	if typeof(value) == 24:
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
