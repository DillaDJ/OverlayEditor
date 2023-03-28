class_name PropertySelectButton
extends Button


enum Mode { Read, Write }

@export var mode : Mode = Mode.Read

@onready var property_select : PropertySelect = sngl_Utility.get_scene_root().get_node("%PropertySelect")

var type_lock : Property.Type = Property.Type.NONE

signal property_linked(property : Property)


func _ready():
	connect("button_down", Callable(self, "start_select_property"))


func start_select_property():
	property_select.connect("property_selected", Callable(self, "link_property"))
	property_select.connect("cancelled", Callable(self, "cancel_link"))
		
	property_select.start_select(mode, type_lock)


func link_property(property : Property) -> void:
	text = property.get_display_name()
	
	property_linked.emit(property)
	
	property_select.disconnect("property_selected", Callable(self, "link_property"))
	property_select.disconnect("cancelled", Callable(self, "cancel_link"))


func cancel_link():
	property_select.disconnect("property_selected", Callable(self, "link_property"))
	property_select.disconnect("cancelled", Callable(self, "cancel_link"))


func reset():
	text = "property"


func set_type_lock(type : Property.Type) -> void:
	type_lock = type
