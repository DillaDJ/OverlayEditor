extends Panel


@onready var int_property_scn 			: PackedScene = preload("res://Overlays/Properties/scn_IntProperty.tscn")
@onready var short_string_property_scn 	: PackedScene = preload("res://Overlays/Properties/scn_ShortStringProperty.tscn")
@onready var string_property_scn 		: PackedScene = preload("res://Overlays/Properties/scn_StringProperty.tscn")
@onready var vector2_property_scn 		: PackedScene = preload("res://Overlays/Properties/scn_Vector2Property.tscn")
@onready var color_property_scn 		: PackedScene = preload("res://Overlays/Properties/scn_ColorProperty.tscn")
@onready var spacer						: PackedScene = preload("res://Overlays/Properties/scn_Spacer.tscn")

@onready var property_container = $ScrollContainer/PropertyContainer


func _ready():
	%MoveTool.connect("overlay_selected", Callable(self, "populate_properties"))
	%MoveTool.connect("overlay_deselected", Callable(self, "clear_properties"))
	
	%Hierarchy.connect("item_selected", Callable(self, "populate_from_idx"))
	%Hierarchy.connect("child_selected", Callable(self, "populate_child_from_idx"))


func populate_from_idx(idx):
	var overlay = %OverlayElements.get_child(idx)
	populate_properties(overlay)


func populate_child_from_idx(parent_idx, child_idx):
	var overlay = %OverlayElements.get_child(parent_idx).get_child(child_idx)
	populate_properties(overlay)


func populate_properties(overlay : Overlay):
	clear_properties()
	
	for property in overlay.overridable_properties:
		if typeof(property) == TYPE_STRING:
			property_container.add_child(spacer.instantiate())
			continue
		
		match property.type:
			Overlay.Property.Type.INT:
				add_property_interface(int_property_scn, property)
			
			Overlay.Property.Type.FLOAT:
				pass
			
			Overlay.Property.Type.STRING_SHORT:
				add_property_interface(short_string_property_scn, property)
			
			Overlay.Property.Type.STRING:
				add_property_interface(string_property_scn, property)
			
			Overlay.Property.Type.VECTOR2:
				add_property_interface(vector2_property_scn, property)
				
			Overlay.Property.Type.COLOR:
				add_property_interface(color_property_scn, property)


func add_property_interface(property_scene : PackedScene, property : Overlay.Property):
	var property_interface = property_scene.instantiate()
	property_container.add_child(property_interface)
	
	var current_value = property.get_property()
	property_interface.set_prop_value(current_value)
	
	property_interface.connect("value_changed", Callable(property, "apply_property"))
	
	property_interface.set_prop_name(property.prop_name + ":")


func clear_properties():
	for property in property_container.get_children():
		property.queue_free()
