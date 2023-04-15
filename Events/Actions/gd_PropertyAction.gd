class_name PropertyAction
extends Action


enum Mode { SET, ADD, SUBTRACT }
@export var mode : Mode = Mode.SET
@export var property : Property

@export var value_container : VariantDataContainer

@export var property_animator : PropertyAnimator


signal value_nulled()


func _init():
	type = Type.PROPERTY


func match_properties(overlay : Overlay) -> void:
	var prop = property.find_equivalent_property(overlay)
	set_property(prop, true)
	
	if prop and value_container.current_data_type == TYPE_OBJECT:
		var matched_value = value_container.get_value().find_equivalent_property(overlay)
		value_container.set_value(matched_value)


func execute():
	if property == null or value_container.get_value() == null:
		return
	
	var new_value
	if typeof(value_container.get_value()) == TYPE_OBJECT:
		match mode:
			Mode.SET:
				new_value = value_container.get_value().get_value()

			Mode.ADD:
				new_value = value_container.get_value().get_value() + property.get_value()

			Mode.SUBTRACT:
				new_value = value_container.get_value().get_value() - property.get_value()
	else:
		match mode:
			Mode.SET:
				new_value = value_container.get_value()

			Mode.ADD:
				new_value = value_container.get_value() + property.get_value()

			Mode.SUBTRACT:
				new_value = value_container.get_value() - property.get_value()


	if property_animator.length != 0:
		property_animator.start(new_value)
		return

	property.set_value(new_value)


func set_mode(new_mode : Mode) -> void:
	mode = new_mode


func set_property(new_property : Property, suppress_fill_in := false) -> void:
	if typeof(value_container.get_value()) == TYPE_OBJECT and value_container.current_data_type != new_property.type:
		value_container.set_property(null)
		value_nulled.emit()
	elif !suppress_fill_in:
		set_value(new_property.get_value())
	
	property_animator.property = new_property
	property = new_property


func set_value(new_value):
	if typeof(new_value) == TYPE_OBJECT:
		value_container.set_property(new_value)
		return
	
	value_container.set_value(new_value)
