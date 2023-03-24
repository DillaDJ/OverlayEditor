class_name PropertySelect
extends Control


@onready var move_tool : MoveTool = %MoveTool
@onready var item_list : ItemList = $PanelContainer/VBoxContainer/ItemList
@onready var confirm_button : Button = $PanelContainer/VBoxContainer/HBoxContainer/Confirm

var cached_overlay : Overlay
var event_property_count := 0
var selected_idx := -1

signal property_selected(property : Property)
signal cancelled()


func _ready():
	item_list.connect("item_selected", Callable(self, "set_selected_index"))
	move_tool.connect("overlay_selected", Callable(self, "populate_properties"))
	
	%Events.connect("event_created", Callable(self, "add_event"))
	$PanelContainer/VBoxContainer/HBoxContainer/Confirm.connect("button_down", Callable(self, "confirm"))
	$PanelContainer/VBoxContainer/HBoxContainer/Cancel.connect("button_down", Callable(self, "cancel"))


func populate_properties(overlay : Overlay):
	event_property_count = 0
	cached_overlay = overlay
	
	item_list.clear()
	item_list.add_item("Event Properties (Read Only):")
	item_list.set_item_disabled(0, true)
	
	for event in overlay.attached_events:
		for property in event.properties:
			item_list.add_item(property.prop_name)
			event_property_count += 1
	
	item_list.add_item("")
	item_list.add_item("Overlay Properties:")
	item_list.set_item_disabled(event_property_count + 1, true)
	item_list.set_item_disabled(event_property_count + 2, true)
	
	for property in overlay.overridable_properties:
		item_list.add_item(property.prop_name)


func add_event(event : Event):
	for property in event.properties:
			item_list.add_item(property.prop_name)
			event_property_count += 1
			
			item_list.move_item(item_list.item_count - 1, event_property_count)


func disable_non_matching_type(type_to_match : Property.Type):
	for i in range(cached_overlay.overridable_properties.size() + event_property_count):
		var property := get_property_from_idx(i)
		var new_idx := convert_to_item_list_idx(i)
		
		if (property.type == Property.Type.STRING or property.type == Property.Type.STRING_SHORT) and \
		(type_to_match == Property.Type.STRING or type_to_match == Property.Type.STRING_SHORT):
			item_list.set_item_disabled(new_idx, false)
			continue
		
		if property.type == type_to_match:
			item_list.set_item_disabled(new_idx, false)
		else:
			item_list.set_item_disabled(new_idx, true)


func start_select(mode : PropertySelectButton.Mode):
	# Prevent writing into event properties
	if mode == PropertySelectButton.Mode.Write:
		for i in range(event_property_count):
			item_list.set_item_disabled(i + 1, true)
	
	show()


func confirm():
	property_selected.emit(get_property_from_idx(selected_idx))
	confirm_button.disabled = true
	hide()


func cancel():
	cancelled.emit()
	hide()


# Utility
func set_selected_index(idx : int) -> void:
	if item_list.is_item_disabled(idx):
		return
	
	selected_idx = convert_to_property_idx(idx)
	confirm_button.disabled = false


func convert_to_item_list_idx(idx : int) -> int:
	var new_idx
	
	if idx < event_property_count:
			new_idx = idx + 1
	else:
			new_idx = idx + 3
	
	return new_idx


func convert_to_property_idx(idx : int) -> int:
	var new_idx
	
	if idx < event_property_count + 1:
			new_idx = idx - 1
	else:
			new_idx = idx - 3
	
	return new_idx


func get_property_from_idx(idx : int) -> Property:
	if idx >= event_property_count:
		return cached_overlay.overridable_properties[idx - event_property_count]
	else:
		var i := 0
		for event in cached_overlay.attached_events:
			for property in event.properties:
				if i == idx:
					return property
				i += 1
	
	return null
