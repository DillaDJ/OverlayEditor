extends VBoxContainer

@onready var layout_container := $FieldLayout
@onready var label : Label = $FieldLayout/Label
@onready var field_matcher : FieldMatcher = $FieldLayout/FieldMatcher

var settings_popup : PopupMenu

var mode : PropertySetTrigger.Mode = PropertySetTrigger.Mode.ANY
var equal := false


func process_settings(id : int) -> void:
	if id != 4:
		settings_popup.set_item_checked(0, false)
		settings_popup.set_item_checked(1, false)
		settings_popup.set_item_checked(2, false)
	
	match id:
		0:
			settings_popup.set_item_checked(0, true)
			set_mode(PropertySetTrigger.Mode.ANY)
			
		1:
			settings_popup.set_item_checked(1, true)
			set_mode(PropertySetTrigger.Mode.LESS)
		
		2:
			settings_popup.set_item_checked(2, true)
			set_mode(PropertySetTrigger.Mode.MORE)
		
		4:
			settings_popup.set_item_checked(4, !settings_popup.is_item_checked(4))
			toggle_equal(!equal)


func toggle_equal(is_equal) -> void:
	equal = is_equal
	set_mode(mode)


func set_mode(new_mode : PropertySetTrigger.Mode) -> void:
	mode = new_mode
	
	if equal:
		match new_mode:
			PropertySetTrigger.Mode.ANY:
				label.text = "is changed to"
			PropertySetTrigger.Mode.LESS:
				label.text = "is less than or equal to"
			PropertySetTrigger.Mode.MORE:
				label.text = "is more than or equal to"
		field_matcher.show()
	else:
		match new_mode:
			PropertySetTrigger.Mode.ANY:
				label.text = "is changed"
				field_matcher.hide()
			PropertySetTrigger.Mode.LESS:
				label.text = "is less than"
				field_matcher.show()
			PropertySetTrigger.Mode.MORE:
				label.text = "is more than"
				field_matcher.show()


func disable_disallowed_modes(property : Property) -> void:
	if !property or !settings_popup:
		return
	
	var allowed_modes = [TYPE_INT, TYPE_FLOAT]
	
	if property.type in allowed_modes:
		settings_popup.set_item_disabled(1, false)
		settings_popup.set_item_disabled(2, false)
	else:
		if mode == PropertySetTrigger.Mode.LESS or mode == PropertySetTrigger.Mode.MORE:
			process_settings(0)
		settings_popup.set_item_disabled(1, true)
		settings_popup.set_item_disabled(2, true)

