extends Overlay


func _ready():
	super()
	
	# Properties
	overridable_properties.append(WriteProperty.new("Text", Property.Type.STRING, Callable(self, "get_text"), Callable(self, "set_text")))
	overridable_properties.append(WriteProperty.new("Text Size", Property.Type.INT, Callable(self, "get_text_size"), Callable(self, "set_text_size")))
	overridable_properties.append(WriteProperty.new("Text Color", Property.Type.COLOR, Callable(self, "get_text_color"), Callable(self, "set_text_color")))


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
