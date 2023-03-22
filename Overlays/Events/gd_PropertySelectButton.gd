class_name PropertySelectButton
extends Button


enum Mode { Read, Write }

@export var mode : Mode = Mode.Read

@onready var property_select : PropertySelect = sngl_Utility.get_scene_root().get_node("%PropertySelect")

signal property_linked(property : Property)


func _ready():
	connect("button_down", Callable(self, "start_select_property"))


func start_select_property():
	property_select.connect("property_selected", Callable(self, "link_property"))
	property_select.connect("cancelled", Callable(self, "cancel"))
	
	property_select.start_select(mode)


func link_property(property : Property) -> void:
	text = property.prop_name.to_lower()
	
	if mode == Mode.Write:
		property_select.disable_non_matching_type(property.type)
	
	property_linked.emit(property)
	
	property_select.disconnect("property_selected", Callable(self, "link_property"))
	property_select.disconnect("cancelled", Callable(self, "cancel"))


func cancel():
	property_select.disconnect("property_selected", Callable(self, "link_property"))
	property_select.disconnect("cancelled", Callable(self, "cancel"))

