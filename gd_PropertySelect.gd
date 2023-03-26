class_name PropertySelect
extends Control


@onready var property_item_scn : PackedScene = preload("res://Overlays/Properties/scn_OverlayPropertyItem.tscn")

@onready var move_tool : MoveTool = %MoveTool
@onready var property_container : Control = $PanelContainer/VBoxContainer/ScrollContainer/PropertyContainer
@onready var confirm_button : Button = $PanelContainer/VBoxContainer/ButtonLayout/Confirm

var selected_property : Property

signal property_selected(property : Property)
signal cancelled()


func _ready():
	var event_menu = %Events
	
#	item_list.connect("item_selected", Callable(self, "set_selected_index"))
	move_tool.connect("overlay_selected", Callable(self, "load_properties_from_overlay"))

	event_menu.connect("event_created", Callable(self, "refresh_events"))
	event_menu.connect("event_deleted", Callable(self, "refresh_events"))
	$PanelContainer/VBoxContainer/ButtonLayout/Confirm.connect("button_down", Callable(self, "confirm"))
	$PanelContainer/VBoxContainer/ButtonLayout/Cancel.connect("button_down", Callable(self, "cancel"))


func load_properties_from_overlay(overlay : Overlay):
	var overlays := sngl_Utility.get_nested_children_flat(overlay)
	overlays.insert(0, overlay)
	
	var property_interface_count := property_container.get_child_count()
	
	for i in range(overlays.size()):
		if i + 1 > property_interface_count:
			var property_item = property_item_scn.instantiate()
			property_container.add_child(property_item)
			
			property_item.connect("property_selected", Callable(self, "set_selected_property"))
			property_item.populate_properties(overlays[i])
		else:
			var property_item = property_container.get_child(i)
			property_item.populate_properties(overlays[i])
			property_item.show()
	
	if overlays.size() < property_interface_count:
		for i in range(property_interface_count - overlays.size()):
			property_container.get_child(i + overlays.size()).hide()


func set_selected_property(property : Property, selected_property_item):
	for property_item in property_container.get_children():
		if property_item == selected_property_item:
			continue
		property_item.deselect_all()
	selected_property = property
	
	confirm_button.disabled = false


func refresh_events(_event : Event = null):
	property_container.get_child(0).refresh_event_properties()


func disable_non_matching_types(type_to_match : Property.Type):
	for property_item in property_container.get_children():
		property_item.match_property_types(type_to_match)


func start_select(mode : PropertySelectButton.Mode):
	# Prevent writing into event properties
	for property_item in property_container.get_children():
		var is_disabled : bool = true if mode == PropertySelectButton.Mode.Write else false
		property_item.set_event_properties_disabled(is_disabled)
		property_item.deselect_all()
	show()


func confirm():
	property_selected.emit(selected_property)
	confirm_button.disabled = true
	hide()


func cancel():
	cancelled.emit()
	hide()
