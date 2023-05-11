class_name PropertyAction
extends Action

@export var add_mode : bool
@export var property : Property
@export var value_container : VariantDataContainer

@export var animating := false
@export var anim_length := 0.0
@export var anim_type : PropertyAnimator.Type

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
	
	# Get new value
	var new_value
	if value_container.current_data_type == TYPE_OBJECT:
		var prop_value = value_container.get_property().get_value()
		new_value = prop_value + property.get_value() if add_mode else prop_value
	else:
		new_value = value_container.get_value() + property.get_value() if add_mode else value_container.get_value()
	
	# Animation
	if animating and anim_length != 0:
		if property is VectorSplitProperty:
			var split_value = new_value
			new_value = property.vector_property.get_value()
			if property.split_axis.x != 0:
				new_value.x = split_value
			elif property.split_axis.y != 0:
				new_value.y = split_value
			elif property.split_axis.z != 0:
				new_value.z = split_value
			elif property.split_axis.w != 0:
				new_value.w = split_value
		property.animator.start(new_value, anim_length, anim_type)
		return
	
	# Non-animating
	if property.animator:
		property.animator.stop()
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
	
	if !new_property.animator:
		animating = false
	property = new_property


func set_value(new_value):
	if typeof(new_value) == TYPE_OBJECT:
		value_container.set_property(new_value)
		return
	
	value_container.set_value(new_value)


func set_anim_length(new_value : float):
	anim_length = new_value


func set_anim_type(new_value : PropertyAnimator.Type):
	anim_type = new_value
