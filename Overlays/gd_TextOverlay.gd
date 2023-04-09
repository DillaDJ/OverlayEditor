extends Overlay


func _ready():
	super()
	type = Type.TEXT
	
	# Properties
	Property.create_write(overridable_properties, "Text", TYPE_STRING_NAME, Callable(self, "get_text"), Callable(self, "set_text"))
	Property.create_write(overridable_properties, "Text Size", TYPE_INT, Callable(self, "get_text_size"), Callable(self, "set_text_size"))
	Property.create_write(overridable_properties, "Text Color", TYPE_COLOR, Callable(self, "get_text_color"), Callable(self, "set_text_color"))


func get_text():
	return self.text


func set_text(new_text):
	self.text = new_text


func get_text_size():
	return get_theme_font_size("font_size")


func set_text_size(new_size):
	add_theme_font_size_override("font_size", new_size)


func get_text_color():
	return get_theme_color("font_color")


func set_text_color(new_color):
	add_theme_color_override("font_color", new_color)
