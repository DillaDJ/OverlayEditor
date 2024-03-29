class_name Inspector
extends Panel


@onready var enum_property_scn 			: PackedScene = preload("res://Properties/Interface/scn_EnumProperty.tscn")
@onready var bool_property_scn 			: PackedScene = preload("res://Properties/Interface/scn_BoolProperty.tscn")
@onready var int_property_scn 			: PackedScene = preload("res://Properties/Interface/scn_IntProperty.tscn")
@onready var short_string_property_scn 	: PackedScene = preload("res://Properties/Interface/scn_ShortStringProperty.tscn")
@onready var string_property_scn 		: PackedScene = preload("res://Properties/Interface/scn_StringProperty.tscn")
@onready var vector2_property_scn 		: PackedScene = preload("res://Properties/Interface/scn_Vector2Property.tscn")
@onready var vector4_property_scn 		: PackedScene = preload("res://Properties/Interface/scn_Vector4Property.tscn")
@onready var color_property_scn 		: PackedScene = preload("res://Properties/Interface/scn_ColorProperty.tscn")
@onready var texture_property_scn 		: PackedScene = preload("res://Properties/Interface/scn_TextureProperty.tscn")
@onready var separator					: PackedScene = preload("res://Utility/OtherInterface/scn_Separator.tscn")

@onready var property_container = $ScrollContainer/PropertyContainer
@onready var overlay_container = %OverlayElements
@onready var transform_tool = %TransformTool


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
	
	for i in range(overlay.overridable_properties.size()):
		var property = overlay.overridable_properties[i]
		if property.hidden_prop:
			continue
		
		match property.type:
			TYPE_PACKED_INT32_ARRAY:
				add_enum_property_interface(property)
			
			TYPE_BOOL:
				add_property_interface(bool_property_scn, property)
			
			TYPE_INT:
				add_property_interface(int_property_scn, property)
			
			TYPE_FLOAT:
				pass
			
			TYPE_STRING:
				add_property_interface(short_string_property_scn, property)
			
			TYPE_STRING_NAME:
				add_property_interface(string_property_scn, property)
			
			TYPE_VECTOR2:
				var property_interface = add_property_interface(vector2_property_scn, property)
				
				# Size and position changes with gizmo manipulations
				if property.prop_name == "Position":
					transform_tool.connect("overlay_translated", Callable(property_interface, "set_value_suppressed"))
				elif property.prop_name == "Size":
					transform_tool.connect("overlay_resized", Callable(property_interface, "set_value_suppressed"))
				
				# Texture panel reset after loading new image
				elif property.prop_name == "Region Position":
					overlay.connect("reset", Callable(property_interface, "set_prop_value").bind(Vector2.ZERO))
				elif property.prop_name == "Region Size":
					overlay.connect("size_reset", Callable(property_interface, "set_prop_value"))
				
			TYPE_VECTOR4:
				var property_interface = add_property_interface(vector4_property_scn, property)
				
				# Texture panel reset after loading new image
				if property.prop_name == "Region Margin":
					overlay.connect("reset", Callable(property_interface, "set_prop_value").bind(Vector4.ZERO))
			
			TYPE_COLOR:
				add_property_interface(color_property_scn, property)
			
			TYPE_PROJECTION:
				add_property_interface(texture_property_scn, property)
		
		add_seperator(overlay.type, property.prop_name)


func add_property_interface(property_scene : PackedScene, property : Property) -> Control:
	var property_interface = property_scene.instantiate()
	property_container.add_child(property_interface)
	
	var current_value = property.get_value()
	property_interface.set_prop_value(current_value)
	property_interface.set_prop_name(property.prop_name + ":")
	
	property_interface.connect("value_changed", Callable(property, "set_value"))
	
	return property_interface


func add_enum_property_interface(property : EnumProperty) -> void:
	var property_interface = enum_property_scn.instantiate()
	property_container.add_child(property_interface)
	
	for option_name in property.types:
		property_interface.add_option(option_name)
	
	var current_value = property.get_value()
	property_interface.set_prop_value(current_value)
	property_interface.set_prop_name(property.prop_name + ":")
	
	property_interface.connect("value_changed", Callable(property, "set_value"))


func add_seperator(overlay_type : Overlay.Type, property_name : String): # Adds a seperator after certain properties
	match overlay_type:
		Overlay.Type.PANEL:
			if property_name not in ["Name", "Color", "Border"]:
				return
		Overlay.Type.TEXTURE_PANEL:
			if property_name not in ["Name", "Minimum Size", "Texture", "Region Margin"]:
				return
		Overlay.Type.TEXT:
			if property_name not in ["Name", "Minimum Size", "Text Font"]:
				return
		Overlay.Type.RICH_TEXT:
			if property_name not in ["Name", "Minimum Size"]:
				return
		Overlay.Type.HBOX:
			if property_name not in ["Name", "Minimum Size"]:
				return
		Overlay.Type.VBOX:
			if property_name not in ["Name", "Minimum Size"]:
				return
		Overlay.Type.GRID:
			if property_name not in ["Name", "Minimum Size"]:
				return
	
	var interface = separator.instantiate()
	property_container.add_child(interface)


func clear_properties():
	for property in property_container.get_children():
		property.queue_free()


func update_property_paths(overlay_to_update : Overlay):
	var overlays := sngl_Utility.get_nested_children_flat(overlay_to_update)
	overlays.insert(0, overlay_to_update)
	
	for overlay in overlays:
		var new_prop_path = overlay_to_update.get_path_to(overlay)
		
		for event in overlay.attached_events:
			for property in event.properties:
				property.prop_path = new_prop_path

		for property in overlay.overridable_properties:
			property.prop_path = new_prop_path
