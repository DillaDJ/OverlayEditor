class_name PropertySelect
extends Control


@onready var move_tool : MoveTool = %MoveTool
@onready var item_list : ItemList = $PanelContainer/VBoxContainer/ItemList
@onready var confirm_button : Button = $PanelContainer/VBoxContainer/HBoxContainer/Confirm

var cached_overlay : Overlay
var cached_event : Event

var selected_idx : int = -1

signal property_selected(property : Property)
signal cancelled()


func _ready():
	item_list.connect("item_selected", Callable(self, "set_selected_index"))
	
	%Events.connect("event_selected", Callable(self, "populate_properties"))
	$PanelContainer/VBoxContainer/HBoxContainer/Confirm.connect("button_down", Callable(self, "confirm"))
	$PanelContainer/VBoxContainer/HBoxContainer/Cancel.connect("button_down", Callable(self, "cancel"))


func populate_properties(event : Event):
	var selected_overlay = move_tool.selected_overlay
	
	item_list.clear()
	item_list.add_item("Event Properties (Read Only):")
	item_list.set_item_disabled(0, true)
	
	for property in event.properties:
		item_list.add_item(property.prop_name)
	
	item_list.add_item("")
	item_list.add_item("Overlay Properties:")
	item_list.set_item_disabled(event.properties.size() + 1, true)
	item_list.set_item_disabled(event.properties.size() + 2, true)
	
	for property in selected_overlay.overridable_properties:
		if typeof(property) == TYPE_STRING:
			continue
		item_list.add_item(property.prop_name)
	
	if selected_overlay != cached_overlay:
		cached_overlay = selected_overlay
	cached_event = event


func select(write_only : bool = false):
	var event_property_count := cached_event.properties.size()
	
	if write_only:
		for i in range(event_property_count):
			item_list.set_item_disabled(i + 1, true)
	else:
		for i in range(event_property_count):
			item_list.set_item_disabled(i + 1, false)
	
	show()


func confirm():
	var selected_property : Property
	var event_property_count := cached_event.properties.size()
	
	if selected_idx >= event_property_count:
		selected_property = cached_overlay.overridable_properties[selected_idx - event_property_count]
	else:
		selected_property = cached_event.properties[selected_idx]
	
	property_selected.emit(selected_property)
	
	confirm_button.disabled = true
	hide()


func cancel():
	cancelled.emit()
	hide()


func set_selected_index(idx : int) -> void:
	if idx < cached_event.properties.size() + 1:
		selected_idx = idx - 1
	else:
		selected_idx = idx - 3
	
	confirm_button.disabled = false
