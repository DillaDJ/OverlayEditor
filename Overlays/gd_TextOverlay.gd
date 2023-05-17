extends Overlay


var editor_font : SystemFont
@export var font : SystemFont 


func _ready():
	super()
	type = Type.TEXT
	
	if !font:
		init_font()
	
	# Properties
	Property.create_write(overridable_properties, "Text", TYPE_STRING_NAME, Callable(self, "get_text"), Callable(self, "set_text"))
	Property.create_write(overridable_properties, "Text Size", TYPE_INT, Callable(self, "get_text_size"), Callable(self, "set_text_size"))
	Property.create_write(overridable_properties, "Text Color", TYPE_COLOR, Callable(self, "get_text_color"), Callable(self, "set_text_color"))
	
	var sys_fonts : Array[String] = []
	sys_fonts.append("Default")
	for font_name in OS.get_system_fonts():
		sys_fonts.append(font_name)
	EnumProperty.create_enum(overridable_properties, "Text Font", sys_fonts, Callable(self, "get_font"), Callable(self, "set_font"))
	
	EnumProperty.create_enum(overridable_properties, "Horizontal Alignment", ["Left", "Middle", "Right", "Fill"], Callable(self, "get_horizontal_alignment"), Callable(self, "set_horizontal_alignment"))
	EnumProperty.create_enum(overridable_properties, "Vertical Alignment", ["Top", "Middle", "Bottom", "Fill"], Callable(self, "get_vertical_alignment"), Callable(self, "set_vertical_alignment"))
	EnumProperty.create_enum(overridable_properties, "Autowrap", ["Off", "Arbitrary", "Word", "Word (Smart)"], Callable(self, "get_autowrap"), Callable(self, "set_autowrap"))
	EnumProperty.create_enum(overridable_properties, "Text Overrun", ["Trim Nothing", "Trim Characters", "Trim Words", "Elipses", "Word Elipses"], Callable(self, "get_text_overrun"), Callable(self, "set_text_overrun"))


func get_text():
	return self.text

func set_text(new_text):
	self.text = new_text


func get_h_alignment():
	return self.horizontal_alignment

func set_h_alignment(value):
	self.horizontal_alignment = value


func get_v_alignment():
	return self.vertical_alignment

func set_v_alignment(value):
	self.vertical_alignment = value


func get_text_overrun():
	return self.text_overrun_behavior

func set_text_overrun(value):
	self.text_overrun_behavior = value


func get_autowrap():
	return self.autowrap_mode

func set_autowrap(value):
	self.autowrap_mode = value


func get_text_size():
	return get_theme_font_size("font_size")

func set_text_size(new_size):
	add_theme_font_size_override("font_size", new_size)


func get_text_color():
	return get_theme_color("font_color")

func set_text_color(new_color):
	add_theme_color_override("font_color", new_color)


func init_font():
		font = SystemFont.new()
		editor_font = sngl_Utility.get_scene_root().get_node("%EditorFont").editor_font
		font.font_names = editor_font.font_names
		add_theme_font_override("font", font)

func get_font() -> int:
	var sys_fonts := OS.get_system_fonts()
	
	if font.font_names.size() == 0:
		return 0
	return sys_fonts.find(font.font_names[0]) + 1

func set_font(id : int) -> void:
	var sys_fonts := OS.get_system_fonts()
	
	if id == 0:
		font.font_names = []
		return
	font.font_names = [sys_fonts[id - 2]]
