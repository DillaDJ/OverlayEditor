class_name PropertyAction
extends Action

@export var add_mode : bool
@export var property : Property
@export var value_container : VariantDataContainer
@export var property_animator : PropertyAnimator

var animating := false

signal value_nulled()


func _init():
	type = Type.PROPERTY


func match_properties(overlay : Overlay) -> void:
	var prop
	
	if property != null:
		prop = property.find_equivalent_property(overlay)
		set_property(prop, true)
	
	if prop and value_container.current_data_type == TYPE_OBJECT:
		var matched_value = value_container.get_property().find_equivalent_property(overlay)
		set_value(matched_value)


func execute() -> void:
	if property == null or value_container.get_value() == null:
		return
	
	var new_value
	if value_container.current_data_type == TYPE_OBJECT:
		var prop_value = value_container.get_property().get_value()
		new_value = prop_value + property.get_value() if add_mode else prop_value
	else:
		new_value = value_container.get_value() + property.get_value() if add_mode else value_container.get_value()

	if animating and property_animator.length != 0:
		property_animator.start(new_value)
		return
	property.set_value(new_value)


func process_settings(id : int):
	match id:
		0:
			set_mode(false)
		1:
			set_mode(true)
		3:
			animating = true


func set_mode(is_add_mode : bool) -> void:
	add_mode = is_add_mode


func set_property(new_property : Property, suppress_fill_in := false) -> void:
	if value_container.current_data_type == TYPE_OBJECT and value_container.get_property().type != new_property.type:
		value_container.set_property(null)
		value_nulled.emit()
	elif !suppress_fill_in: # Keep user values when changed
		set_value(new_property.get_value())
	
	var anim_allowed_modes := [TYPE_INT, TYPE_FLOAT, TYPE_VECTOR2, TYPE_VECTOR4, TYPE_COLOR]
	if new_property.type in anim_allowed_modes:
		property_animator.property = new_property
	else:
		animating = false
	property = new_property


func set_value(new_value):
	if typeof(new_value) == TYPE_OBJECT:
		value_container.set_property(new_value)
		return
	
	value_container.set_value(new_value)
