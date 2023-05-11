extends PanelContainer


@onready var container : Control = $HorizontalLayout/VerticalLayout/HorizontalLayout
@onready var set_add_label : Control = $HorizontalLayout/VerticalLayout/HorizontalLayout/SetAddLabel
@onready var property_selector : Control = $HorizontalLayout/VerticalLayout/HorizontalLayout/PropertySelector
@onready var mode_label : Label = $HorizontalLayout/VerticalLayout/HorizontalLayout/ModeLabel
@onready var animation_options : Control = $HorizontalLayout/VerticalLayout/Options
@onready var anim_time : SpinBox = $HorizontalLayout/VerticalLayout/Options/SpinBox
@onready var anim_type : OptionButton = $HorizontalLayout/VerticalLayout/Options/OptionButton

var current_property : Property
var settings_popup : PopupMenu
var add_mode := false
var animating := false


func _ready():
	var field_matcher = $HorizontalLayout/VerticalLayout/HorizontalLayout/FieldMatcher
	property_selector.connect("property_linked", Callable(field_matcher, "match_property"))


func process_settings(id : int) -> void:
	if id != 3:
		settings_popup.set_item_checked(0, false)
		settings_popup.set_item_checked(1, false)
	
	match id:
		0:
			settings_popup.set_item_checked(0, true)
			set_mode(false)
			
		1:
			settings_popup.set_item_checked(1, true)
			set_mode(true)
			
		3:
			settings_popup.set_item_checked(3, !animating)
			toggle_animating(!animating)


func toggle_animating(is_animating):
	animating = is_animating
	
	if animating:
		animation_options.show()
	else:
		animation_options.hide()


func set_mode(is_add_mode : bool):
	add_mode = is_add_mode
	
	if is_add_mode:
		mode_label.text = "Add"
		container.move_child(set_add_label, 4)
		property_selector.move_to_front()
	else:
		mode_label.text = "Set"
		container.move_child(property_selector, 1)
		container.move_child(set_add_label, 2)


func disable_disallowed_modes(property : Property):
	if !property or !settings_popup:
		return
	
	var add_allowed_modes  := [TYPE_INT, TYPE_FLOAT, TYPE_VECTOR2, TYPE_VECTOR4, TYPE_COLOR, TYPE_STRING, TYPE_STRING_NAME]
	var anim_allowed_modes := [TYPE_INT, TYPE_FLOAT, TYPE_VECTOR2, TYPE_VECTOR4, TYPE_COLOR]
	
	if property.type in add_allowed_modes:
		settings_popup.set_item_disabled(1, false)
	else:
		if add_mode:
			process_settings(0)
		settings_popup.set_item_disabled(1, true)
	
	if property.type in anim_allowed_modes:
		settings_popup.set_item_disabled(3, false)
	else:
		settings_popup.set_item_checked(3, false)
		settings_popup.set_item_disabled(3, true)
		toggle_animating(false)

