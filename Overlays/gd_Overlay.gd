class_name Overlay
extends Control


var overridable_properties 	: Array[Property] = []
var attached_events 		: Array[Event] = []

signal name_changed(new_name : String)
signal hierarchy_order_changed(idx : int)
signal transformed()


func _ready() -> void:
	# Hidden Properties
	overridable_properties.append(WriteProperty.new("Visibility", Property.Type.BOOL, Callable(self, "is_visible"), Callable(self, "set_visible"), true))
	overridable_properties.append(WriteProperty.new("Hierarchy Order", Property.Type.INT, Callable(self, "get_index"), Callable(self, "set_overlay_index"), true))
	
	# Properties
	overridable_properties.append(WriteProperty.new("Name", 		Property.Type.STRING_SHORT, Callable(self, "get_name"), Callable(self, "set_overlay_name")))
	overridable_properties.append(WriteProperty.new("Position", 	Property.Type.VECTOR2, Callable(self, "get_global_position"), Callable(self, "set_overlay_pos")))
	overridable_properties.append(WriteProperty.new("Size", 		Property.Type.VECTOR2, Callable(self, "get_size"), Callable(self, "set_overlay_size")))
	overridable_properties.append(WriteProperty.new("Minimum Size", Property.Type.VECTOR2, Callable(self, "get_custom_minimum_size"), Callable(self, "set_overlay_min_size")))


func set_overlay_index(idx : int) -> void:
	var parent = get_parent()
	var child_count = parent.get_child_count()
	
	if idx > child_count:
		idx = child_count
	
	hierarchy_order_changed.emit(idx)
	parent.move_child(self, idx)


func set_overlay_name(new_name : String) -> void:
	set_name(new_name)
	name_changed.emit(new_name)


func set_overlay_pos(new_pos) -> void:
	set_global_position(new_pos)
	transformed.emit()


func set_overlay_size(new_size) -> void:
	set_size(new_size)
	transformed.emit()


func set_overlay_min_size(new_size) -> void:
	set_custom_minimum_size(new_size)
	
	if size.x < new_size.x:
		size.x = new_size.x
	
	if size.y < new_size.y:
		size.y = new_size.y
	
	transformed.emit()
