class_name VectorSplitProperty 
extends Property


var vector_property : Property
var split_axis : Vector4 = Vector4.ZERO
var last_seen


static func split_vector(property : Property, is_hidden : bool = false) -> Array[VectorSplitProperty]:
	if property.type != TYPE_VECTOR2 and property.type != TYPE_VECTOR4:
		printerr("Can only split vector properties!")
		return []
	
	var split_axis_list : Array[VectorSplitProperty] = []
	
	var x_split = VectorSplitProperty.new()
	var y_split = VectorSplitProperty.new()
	x_split.setup_vec_split(property, Vector4(1, 0, 0, 0), is_hidden)
	y_split.setup_vec_split(property, Vector4(0, 1, 0, 0), is_hidden)
	split_axis_list.append(x_split)
	split_axis_list.append(y_split)
	
	if property.type == TYPE_VECTOR4:
		var z_split = VectorSplitProperty.new()
		var w_split = VectorSplitProperty.new()
		z_split.setup_vec_split(property, Vector4(0, 0, 1, 0), is_hidden)
		w_split.setup_vec_split(property, Vector4(0, 0, 0, 1), is_hidden)
		split_axis_list.append(z_split)
		split_axis_list.append(w_split)
	
	return split_axis_list


func setup_vec_split(vector_prop : Property, axis : Vector4, is_hidden : bool = false):
	if vector_prop.type != TYPE_VECTOR2 and vector_prop.type != TYPE_VECTOR4:
		printerr("Can only create a vector split property using vector properties")
		return
	
	if axis == Vector4.ZERO:
		printerr("A vector split property requires an axis to split from")
		return
	
	if vector_prop.type == TYPE_VECTOR2 and axis.x == 0 and axis.y == 0:
		printerr("A Vector2 split property has to split from either the X or Y axis")
		return
	
	var axis_name : String = "?"
	if axis.x != 0:
		split_axis.x = 1
		axis_name = "x"
	elif axis.y != 0:
		split_axis.y = 1
		axis_name = "y"
	elif axis.z != 0:
		split_axis.z = 1
		axis_name = "z"
	elif axis.w != 0:
		split_axis.w = 1
		axis_name = "w"
	
	if vector_prop.write:
		setup_write(vector_prop.prop_name + "." + axis_name, TYPE_FLOAT, Callable(self, "get_vector_value_from_axis"), Callable(self, "set_vector_value_from_axis"), is_hidden)
	else:
		setup(vector_prop.prop_name + "." + axis_name, TYPE_FLOAT, Callable(self, "get_vector_value_from_axis"), is_hidden)
	
	vector_property = vector_prop
	last_seen = vector_prop.get_value()
	vector_prop.connect("property_set", Callable(self, "check_if_changed"))


func get_vector_value_from_axis() -> float:
	var vector = vector_property.get_value()
	
	if split_axis.x == 1:
		return vector.x
	elif split_axis.y == 1:
		return vector.y
	elif split_axis.z == 1:
		return vector.z
	elif split_axis.w == 1:
		return vector.w
	return 0


func set_vector_value_from_axis(value_to_set) -> void:
	var vector = vector_property.get_value()
	
	if split_axis.x == 1:
		vector.x = value_to_set
	elif split_axis.y == 1:
		vector.y = value_to_set
	elif split_axis.z == 1:
		vector.z = value_to_set
	elif split_axis.w == 1:
		vector.w = value_to_set
	
	vector_property.set_value(vector)


func check_if_changed():
	var vector = vector_property.get_value()
	
	if split_axis.x == 1 and last_seen.x != vector.x:
		property_set.emit()
	elif split_axis.y == 1 and last_seen.x != vector.x:
		property_set.emit()
	elif split_axis.z == 1 and last_seen.x != vector.x:
		property_set.emit()
	elif split_axis.w == 1 and last_seen.x != vector.x:
		property_set.emit()
	
	last_seen = vector
