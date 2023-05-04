extends Overlay


func _ready() -> void:
	super()
	type = Type.PANEL
	
	# Properties
	Property.create_write(overridable_properties, "Color", TYPE_COLOR, Callable(self, "get_overlay_color"), Callable(self, "set_overlay_color"))
	
	Property.create_formatting(overridable_properties)
	
	Property.create_write(overridable_properties, "Border Color", TYPE_COLOR, Callable(self, "get_border_color"), Callable(self, "set_border_color"))
	Property.create_write(overridable_properties, "Border", TYPE_VECTOR4, Callable(self, "get_border"), Callable(self, "set_border"))
	
	Property.create_formatting(overridable_properties)
	
	Property.create_write(overridable_properties, "Rounding", TYPE_VECTOR4, Callable(self, "get_rounding"), Callable(self, "set_rounding"))
	
	make_stylebox_unique()


func get_overlay_color() -> Color:
	var stylebox : StyleBoxFlat = get_stylebox()
	return stylebox.bg_color


func set_overlay_color(new_color) -> void:
	var stylebox : StyleBoxFlat = get_stylebox()
	stylebox.bg_color = new_color


func get_border() -> Vector4:
	var border := Vector4.ZERO
	var stylebox : StyleBoxFlat = get_stylebox()
	border.x = stylebox.get_border_width(SIDE_LEFT)
	border.y = stylebox.get_border_width(SIDE_TOP)
	border.z = stylebox.get_border_width(SIDE_RIGHT)
	border.w = stylebox.get_border_width(SIDE_BOTTOM)
	return border


func set_border(new_border : Vector4) -> void:
	var stylebox : StyleBoxFlat = get_stylebox()
	stylebox.set_border_width(SIDE_LEFT, int(new_border.x))
	stylebox.set_border_width(SIDE_TOP, int(new_border.y))
	stylebox.set_border_width(SIDE_RIGHT, int(new_border.z))
	stylebox.set_border_width(SIDE_BOTTOM, int(new_border.w))


func get_border_color() -> Color:
	var stylebox : StyleBoxFlat = get_stylebox()
	return stylebox.border_color


func set_border_color(new_color : Color) -> void:
	var stylebox : StyleBoxFlat = get_stylebox()
	stylebox.border_color = new_color


func get_rounding() -> Vector4:
	var rounding := Vector4.ZERO
	var stylebox : StyleBoxFlat = get_stylebox()
	rounding.x = stylebox.get_corner_radius(CORNER_TOP_LEFT)
	rounding.y = stylebox.get_corner_radius(CORNER_TOP_RIGHT)
	rounding.z = stylebox.get_corner_radius(CORNER_BOTTOM_LEFT)
	rounding.w = stylebox.get_corner_radius(CORNER_BOTTOM_RIGHT)
	return rounding


func set_rounding(new_rounding : Vector4):
	var stylebox : StyleBoxFlat = get_stylebox()
	stylebox.set_corner_radius(CORNER_TOP_LEFT, int(new_rounding.x))
	stylebox.set_corner_radius(CORNER_TOP_RIGHT, int(new_rounding.y))
	stylebox.set_corner_radius(CORNER_BOTTOM_LEFT, int(new_rounding.z))
	stylebox.set_corner_radius(CORNER_BOTTOM_RIGHT, int(new_rounding.w))


func make_stylebox_unique() -> void:
	var stylebox = get_theme_stylebox("panel").duplicate()
	remove_theme_stylebox_override("panel")
	add_theme_stylebox_override("panel", stylebox)


func get_stylebox() -> StyleBoxFlat:
	var stylebox = get_theme_stylebox("panel")
	return stylebox
