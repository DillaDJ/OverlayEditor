class_name Inspector
extends Panel


@onready var enum_property_scn 			: PackedScene = preload("res://Properties/scn_EnumProperty.tscn")
@onready var bool_property_scn 			: PackedScene = preload("res://Properties/scn_BoolProperty.tscn")
@onready var int_property_scn 			: PackedScene = preload("res://Properties/scn_IntProperty.tscn")
@onready var short_string_property_scn 	: PackedScene = preload("res://Properties/scn_ShortStringProperty.tscn")
@onready var string_property_scn 		: PackedScene = preload("res://Properties/scn_StringProperty.tscn")
@onready var vector2_property_scn 		: PackedScene = preload("res://Properties/scn_Vector2Property.tscn")
@onready var vector4_property_scn 		: PackedScene = preload("res://Properties/scn_Vector4Property.tscn")
@onready var color_property_scn 		: PackedScene = preload("res://Properties/scn_ColorProperty.tscn")
@onready var texture_property_scn 		: PackedScene = preload("res://Properties/scn_TextureProperty.tscn")
@onready var spacer						: PackedScene = preload("res://Properties/scn_Spacer.tscn")

@onready var property_container = $ScrollContainer/PropertyContainer
@onready var overlay_container = %OverlayElements


func _ready():
	var editor = sngl_Utility.get_scene_root()
	
	editor.connect("overlay_click_selected", Callable(self, "populate_properties"))
	editor.connect("overlay_deselected", Callable(self, "clear_properties"))
	
	%Hierarchy.connect("item_selected", Callable(self, "populate_from_path"))


func populate_from_path(path : String):
	var overlay : Control = overlay_container.get_node(path)
	update_property_paths(overlay)
	populate_properties(overlay)


func populate_properties(overlay : Overlay):
	clear_properties()
	
	for property in overlay.overridable_properties:
		if property.hidden:
			continue
		
		match property.type:
			Property.Type.ENUM:
				add_enum_property_interface(property)
			
			Property.Type.BOOL:
				add_property_interface(bool_property_scn, property)
			
			Property.Type.INT:
				add_property_interface(int_property_scn, property)
			
			Property.Type.FLOAT:
				pass
			
			Property.Type.STRING_SHORT:
				add_property_interface(short_string_property_scn, property)
			
			Property.Type.STRING:
				add_property_interface(string_property_scn, property)
			
			Property.Type.VECTOR2:
				var property_interface = add_property_interface(vector2_property_scn, property)
				
				# Size and position changes with gizmo manipulations
				var transform_tool = %TransformTool
				if property.prop_name == "Position":
					transform_tool.connect("overlay_translated", Callable(property_interface, "set_prop_value_suppressed"))
				elif property.prop_name == "Size":
					transform_tool.connect("overlay_resized", Callable(property_interface, "set_prop_value_suppressed"))
				
				# Texture panel reset after loading new image
				elif property.prop_name == "Region Position":
					overlay.connect("reset", Callable(property_interface, "set_prop_value").bind(Vector2.ZERO))
				elif property.prop_name == "Region Size":
					overlay.connect("size_reset", Callable(property_interface, "set_prop_value"))
				
			Property.Type.VECTOR4:
				var property_interface = add_property_interface(vector4_property_scn, property)
				
				# Texture panel reset after loading new image
				if property.prop_name == "Region Margin":
					overlay.connect("reset", Callable(property_interface, "set_prop_value").bind(Vector4.ZERO))
			
			Property.Type.COLOR:
				add_property_interface(color_property_scn, property)
			
			Property.Type.TEXTURE:
				add_property_interface(texture_property_scn, property)


func add_property_interface(property_scene : PackedScene, property : Property) -> Control:
	var property_interface = property_scene.instantiate()
	property_container.add_child(property_interface)
	
	var current_value = property.get_property()
	property_interface.set_prop_value(current_value)
	property_interface.set_prop_name(property.prop_name + ":")
	
	property_interface.connect("value_changed", Callable(property, "set_property"))
	
	return property_interface


func add_enum_property_interface(property : WriteProperty.EnumProperty) -> void:
	var property_interface = enum_property_scn.instantiate()
	property_container.add_child(property_interface)
	
	for option_name in property.types:
		property_interface.add_option(option_name)
	
	var current_value = property.get_property()
	property_interface.set_prop_value(current_value)
	property_interface.set_prop_name(property.prop_name + ":")
	
	property_interface.connect("value_changed", Callable(property, "set_property"))


func clear_properties():
	for property in property_container.get_children():
		property.queue_free()


func update_property_paths(overlay : Overlay):
	var overlays := sngl_Utility.get_nested_children_flat(overlay)
	overlays.insert(0, overlay)
	
	for i_overlay in overlays:
		var new_prop_path = overlay.get_path_to(i_overlay)
		
		for event in i_overlay.attached_events:
			for property in event.properties:
				property.prop_path = new_prop_path

		for property in i_overlay.overridable_properties:
			property.prop_path = new_prop_path
