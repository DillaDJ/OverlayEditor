class_name PropertySelectItem
extends VBoxContainer


@onready var caret_button 	: Button = $HeaderBG/HeaderLayout/Caret
@onready var overlay_info 	: Label = $HeaderBG/HeaderLayout/OverlayInfo
@onready var list_container : Control = $PropertyBG

@onready var event_label 	: Label = $PropertyBG/PropertyLists/EventLabel
@onready var event_list 	: ItemList = $PropertyBG/PropertyLists/EventPropertyList
@onready var overlay_label 	: Label = $PropertyBG/PropertyLists/OverlayLabel
@onready var overlay_list 	: ItemList = $PropertyBG/PropertyLists/OverlayPropertyList

var attached_overlay : Overlay

signal property_selected(property : Property, selected_property_item : PropertySelectItem)


func _ready():
	caret_button.connect("toggled", Callable(self, "toggle_item_visibility"))
	event_list.connect("item_selected", Callable(self, "event_property_selected"))
	overlay_list.connect("item_selected", Callable(self, "overlay_property_selected"))


func toggle_item_visibility(showing : bool):
	if showing:
		caret_button.icon = sngl_Utility.caret_on
		list_container.show()
	else:
		caret_button.icon = sngl_Utility.caret_off
		list_container.hide()


func populate_properties(overlay : Overlay):
	if attached_overlay == overlay:
		return
	
	overlay_info.text = "%s (%s)" % [overlay.name, overlay.get_type_name()]
	attached_overlay = overlay
	
	overlay_list.clear()
	
	for property in overlay.overridable_properties:
		overlay_list.add_item(property.prop_name)
	
	refresh_event_properties()


func match_property_types(type_to_match : Variant.Type):
	if type_to_match == TYPE_NIL:
		set_overlay_properties_disabled(false)
		return
	
	for i in range(attached_overlay.attached_events.size()):
		var event : Event = attached_overlay.attached_events[i]
		for j in range(event.properties.size()):
			check_property_match(event.properties[j], type_to_match, event_list, j)
	
	for i in range(attached_overlay.overridable_properties.size()):
		var property := attached_overlay.overridable_properties[i]
		check_property_match(property, type_to_match, overlay_list, i)


func check_property_match(property : Property, type_to_match : Variant.Type, list : ItemList,  item_idx : int):
	if (property.type == TYPE_STRING or property.type == TYPE_STRING_NAME) and \
		(type_to_match == TYPE_STRING or type_to_match == TYPE_STRING_NAME):
			list.set_item_disabled(item_idx, false)
			return

	if property.type == type_to_match:
		list.set_item_disabled(item_idx, false)
	else:
		list.set_item_disabled(item_idx, true)


func refresh_event_properties():
	event_list.clear()
	
	for event in attached_overlay.attached_events:
		for property in event.properties:
			event_list.add_item(property.prop_name)
	
	if event_list.item_count == 0:
		event_list.hide()
		event_label.hide()
	else:
		event_list.show()
		event_label.show()


func set_event_properties_disabled(value : bool):
	for i in range(event_list.item_count):
		event_list.set_item_disabled(i, value)


func set_overlay_properties_disabled(value : bool):
	for i in range(overlay_list.item_count):
		overlay_list.set_item_disabled(i, value)


func event_property_selected(idx : int) -> void:
	if event_list.is_item_disabled(idx):
		return
	
	overlay_list.deselect_all()
	var event_idx := 0
	
	for i in range(attached_overlay.attached_events.size()):
		if idx - attached_overlay.attached_events[i].properties.size() < 0:
			event_idx = i
			break
		idx -= attached_overlay.attached_events[i].properties.size()
	
	property_selected.emit(attached_overlay.attached_events[event_idx].properties[idx], self)


func overlay_property_selected(idx : int):
	if overlay_list.is_item_disabled(idx):
		return
	
	event_list.deselect_all()
	
	property_selected.emit(attached_overlay.overridable_properties[idx], self)


func deselect_all():
	event_list.deselect_all()
	overlay_list.deselect_all()
