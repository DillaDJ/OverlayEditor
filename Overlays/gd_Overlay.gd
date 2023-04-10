class_name Overlay
extends Control

enum Type { NULL, PANEL, TEXTURE_PANEL, TEXT, HBOX, VBOX, GRID }
var type : Type

var overridable_properties 	: Array[Property] = []
@export var attached_events : Array[Event] = []

signal name_changed(new_name : String)
signal hierarchy_order_changed(idx : int)


func _ready() -> void:
	# Hidden Properties
	Property.create_write(overridable_properties, "Visibility", 	TYPE_BOOL, Callable(self, "is_visible"), Callable(self, "set_visible"), true)
	Property.create_write(overridable_properties, "Hierarchy Order",TYPE_INT, Callable(self, "get_index"), Callable(self, "set_overlay_index"), true)
	
	# Properties
	Property.create_write(overridable_properties, "Name", 			TYPE_STRING, Callable(self, "get_name"), Callable(self, "set_overlay_name"))
	Property.create_write(overridable_properties, "Position", 		TYPE_VECTOR2, Callable(self, "get_global_position"), Callable(self, "set_overlay_pos"))
	Property.create_write(overridable_properties, "Size", 			TYPE_VECTOR2, Callable(self, "get_size"), Callable(self, "set_overlay_size"))
	Property.create_write(overridable_properties, "Minimum Size", 	TYPE_VECTOR2, Callable(self, "get_custom_minimum_size"), Callable(self, "set_overlay_min_size"))


func _physics_process(delta):
	for event in attached_events:
		event.process(delta)


# Property Setters
func set_overlay_index(idx : int) -> void:
	var parent = get_parent()
	var child_count = parent.get_child_count()
	
	if idx > child_count:
		idx = child_count
	
	hierarchy_order_changed.emit(idx)
	parent.move_child(self, idx)


func set_overlay_name(new_name : String) -> void:
	new_name = sngl_Utility.get_unique_name_amongst_siblings(new_name, self, get_parent())
	set_name(new_name)
	
	name_changed.emit(new_name)


func set_overlay_pos(new_pos) -> void:
	set_global_position(new_pos)


func set_overlay_size(new_size) -> void:
	set_size(new_size)


func set_overlay_min_size(new_size) -> void:
	set_custom_minimum_size(new_size)
	
	if size.x < new_size.x:
		size.x = new_size.x
	
	if size.y < new_size.y:
		size.y = new_size.y


# Utility
func get_type_name() -> String:
	match type:
		Type.PANEL:
			return "Panel Overlay"
		Type.TEXTURE_PANEL:
			return "Textured Panel Overlay"
		Type.TEXT:
			return "Text Overlay"
		Type.HBOX:
			return "Horizontal Box Container"
		Type.VBOX:
			return "Vertical Box Container"
		Type.GRID:
			return "Grid Container"
	
	return ""


func find_property(prop_name : String) -> Property:
	for property in overridable_properties:
		if property.prop_name == prop_name:
			return property
	return null
