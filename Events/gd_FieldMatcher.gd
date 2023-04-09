class_name FieldMatcher
extends HBoxContainer


@onready var checkbox 	: CheckBox = $CheckBox
@onready var spinbox 	: SpinBox = $SpinBox
@onready var line_edit 	: LineEdit = $LineEdit

@onready var vector 	: Control = $Vector
@onready var x_spinbox 	: SpinBox = $Vector/XCoords/SpinBox
@onready var y_spinbox 	: SpinBox = $Vector/YCoords/SpinBox
@onready var z_coords 	: Control = $Vector/ZCoords
@onready var z_spinbox 	: SpinBox = $Vector/ZCoords/SpinBox
@onready var w_coords 	: Control = $Vector/WCoords
@onready var w_spinbox 	: SpinBox = $Vector/WCoords/SpinBox

@onready var color_picker : ColorPickerButton = $ColorPickerButton

@onready var property_selector : PropertySelectButton = $PropertySelector

var using_property_field : bool = false

var matched_property : Property


signal field_changed(new_value)


func _ready():
	checkbox.connect("button_down", Callable(self, "bool_change_field"))
	spinbox.connect("value_changed", Callable(self, "change_field"))
	x_spinbox.connect("value_changed", Callable(self, "vector_change_field"))
	y_spinbox.connect("value_changed", Callable(self, "vector_change_field"))
	z_spinbox.connect("value_changed", Callable(self, "vector_change_field"))
	w_spinbox.connect("value_changed", Callable(self, "vector_change_field"))
	
	line_edit.connect("text_submitted", Callable(self, "change_field"))
	color_picker.connect("color_changed", Callable(self, "change_field"))
	property_selector.connect("property_linked", Callable(self, "change_field"))
	
	$ToggleProperty.connect("button_down", Callable(self, "toggle_property"))


func toggle_property():
	if matched_property:
		using_property_field = !using_property_field
		match_property(matched_property)


func match_property(match_prop : Property):
	matched_property = match_prop
	
	checkbox.hide()
	spinbox.hide()
	line_edit.hide()
	vector.hide()
	color_picker.hide()
	property_selector.hide()
	
	if using_property_field:
		property_selector.set_type_lock(match_prop.type)
		property_selector.show()
		return
	
	match match_prop.type:
		TYPE_BOOL:
			checkbox.show()
		
		TYPE_INT:
			spinbox.step = 1
			spinbox.show()
		
		TYPE_FLOAT:
			spinbox.step = .1
			spinbox.show()
		
		TYPE_STRING:
			line_edit.show()
		
		TYPE_STRING_NAME:
			line_edit.show()
		
		TYPE_VECTOR2:
			vector.show()
			z_coords.hide()
			w_coords.hide()
		
		TYPE_VECTOR4:
			vector.show()
			z_coords.show()
			w_coords.show()
		
		TYPE_COLOR:
			color_picker.show()
		
		TYPE_PROJECTION:
			pass


func reset():
	checkbox.hide()
	spinbox.hide()
	line_edit.hide()
	vector.hide()
	color_picker.hide()
	property_selector.hide()
	property_selector.reset()


func reset_property():
	property_selector.reset()


func fill_field(property : Property, value_to_set):
	match property.type:
		TYPE_BOOL:
			checkbox.set_pressed(value_to_set)
		
		TYPE_INT:
			spinbox.value = value_to_set
		
		TYPE_FLOAT:
			spinbox.value = value_to_set
		
		TYPE_STRING:
			line_edit.text = value_to_set
		
		TYPE_STRING_NAME:
			line_edit.text = value_to_set
		
		TYPE_VECTOR2:
			x_spinbox.value = value_to_set.x
			y_spinbox.value = value_to_set.y
		
		TYPE_VECTOR4:
			x_spinbox.value = value_to_set.x
			y_spinbox.value = value_to_set.y
			z_spinbox.value = value_to_set.z
			w_spinbox.value = value_to_set.w
		
		TYPE_COLOR:
			color_picker.color = value_to_set
		
		TYPE_PROJECTION:
			pass


func change_field(value):
	field_changed.emit(value)


func bool_change_field():
	field_changed.emit(checkbox.button_pressed)


func vector_change_field(_value):
	if matched_property.type == TYPE_VECTOR2:
		var new_vector : Vector2 = Vector2.ZERO
		new_vector.x = x_spinbox.value
		new_vector.y = y_spinbox.value
		field_changed.emit(new_vector)
		
	elif matched_property.type == TYPE_VECTOR4:
		var new_vector : Vector4 = Vector4.ZERO
		new_vector.x = x_spinbox.value
		new_vector.y = y_spinbox.value
		new_vector.z = z_spinbox.value
		new_vector.w = w_spinbox.value
		field_changed.emit(new_vector)
