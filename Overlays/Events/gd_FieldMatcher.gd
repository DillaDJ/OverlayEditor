class_name FieldMatcher
extends HBoxContainer


@onready var checkbox 	: CheckBox = $CheckBox
@onready var spinbox 	: SpinBox = $SpinBox
@onready var line_edit 	: LineEdit = $LineEdit

@onready var vector 	: Control = $Vector
@onready var x_spinbox 	: SpinBox = $Vector/XCoords/SpinBox
@onready var y_spinbox 	: SpinBox = $Vector/YCoords/SpinBox
@onready var z_spinbox 	: SpinBox = $Vector/ZCoords/SpinBox
@onready var w_spinbox 	: SpinBox = $Vector/WCoords/SpinBox

@onready var color_picker : ColorPickerButton = $ColorPickerButton

@onready var property_selector : PropertySelectButton = $PropertySelector


var using_property_field : bool = false

var matched_property : Property

signal field_changed(new_value)


func _ready():
	checkbox.connect("button_down", Callable(self, "emit_field_change"))
	spinbox.connect("changed", Callable(self, "emit_field_change"))
	x_spinbox.connect("changed", Callable(self, "emit_field_change"))
	y_spinbox.connect("changed", Callable(self, "emit_field_change"))
	z_spinbox.connect("changed", Callable(self, "emit_field_change"))
	w_spinbox.connect("changed", Callable(self, "emit_field_change"))
	
	line_edit.connect("text_submitted", Callable(self, "quick_emit_field_changed"))
	color_picker.connect("color_changed", Callable(self, "quick_emit_field_changed"))
	property_selector.connect("property_linked", Callable(self, "quick_emit_field_changed"))
	
	$ToggleProperty.connect("button_down", Callable(self, "toggle_property"))


func toggle_property():
	using_property_field = !using_property_field
	match_property(matched_property)


func match_property(property : Property):
	matched_property = property
	
	checkbox.hide()
	spinbox.hide()
	line_edit.hide()
	vector.hide()
	color_picker.hide()
	property_selector.hide()
	
	if using_property_field:
		property_selector.show()
		return
	
	match property.type:
		Property.Type.BOOL:
			checkbox.show()
		
		Property.Type.INT:
			spinbox.step = 1
			spinbox.show()
		
		Property.Type.FLOAT:
			spinbox.step = .1
			spinbox.show()
		
		Property.Type.STRING_SHORT:
			line_edit.show()
		
		Property.Type.STRING:
			line_edit.show()
		
		Property.Type.VECTOR2:
			z_spinbox.hide()
			w_spinbox.hide()
			vector.show()
		
		Property.Type.VECTOR4:
			z_spinbox.show()
			w_spinbox.show()
			vector.show()
		
		Property.Type.COLOR:
			color_picker.show()
		
		Property.Type.TEXTURE:
			pass
		
	show()


func fill_field(property : Property):
	var value_to_set = property.get_property()
	
	match property.type:
		Property.Type.BOOL:
			checkbox.set_pressed(value_to_set)
		
		Property.Type.INT:
			spinbox.value = value_to_set
		
		Property.Type.FLOAT:
			spinbox.value = value_to_set
		
		Property.Type.STRING_SHORT:
			line_edit.text = value_to_set
		
		Property.Type.STRING:
			line_edit.text = value_to_set
		
		Property.Type.VECTOR2:
			x_spinbox.value = value_to_set.x
			y_spinbox.value = value_to_set.y
		
		Property.Type.VECTOR4:
			x_spinbox.value = value_to_set.x
			y_spinbox.value = value_to_set.y
			z_spinbox.value = value_to_set.z
			w_spinbox.value = value_to_set.w
		
		Property.Type.COLOR:
			color_picker.color = value_to_set
		
		Property.Type.TEXTURE:
			pass


func emit_field_change():
	match matched_property.type:
		Property.Type.BOOL:
			field_changed.emit(checkbox.button_pressed)
		
		Property.Type.INT:
			field_changed.emit(spinbox.value)
		
		Property.Type.FLOAT:
			field_changed.emit(spinbox.value)
		
		Property.Type.VECTOR2:
			var new_vector : Vector2 = Vector2.ZERO
			new_vector.x = x_spinbox.value
			new_vector.y = y_spinbox.value
			field_changed.emit(new_vector)
		
		Property.Type.VECTOR4:
			var new_vector : Vector4 = Vector4.ZERO
			new_vector.x = x_spinbox.value
			new_vector.y = y_spinbox.value
			new_vector.z = z_spinbox.value
			new_vector.w = w_spinbox.value
			field_changed.emit(new_vector)
		
		Property.Type.TEXTURE:
			pass


func quick_emit_field_changed(value):
	field_changed.emit(value)
