extends VBoxContainer


@onready var editor_font : SystemFont = preload("res://Utility/Appearance/thm_editor_font.tres")
@onready var font_select 	: OptionButton = $OptionButton


signal system_font_changed(font_id : String)


func _ready() -> void:
	font_select.connect("item_selected", Callable(self, "select_system_font"))
	load_system_fonts()


func load_system_fonts():
	var fonts := OS.get_system_fonts()
	font_select.add_item("Default")
	
	for font_name in fonts:
		font_select.add_item(font_name)


func load_font_from_cfg(id : String):
	var int_id : int
	if id != "---":
		id = id.lstrip('-')
		int_id = id.to_int()
	font_select.select(int_id)
	select_system_font(int_id)


func select_system_font(id : int):
	var font_name := ""
	var font_id := "---"
	
	if id != 0:
		font_name = OS.get_system_fonts()[id - 1]
		
		font_id = "%d" % id
		if font_id.length() == 1:
			font_id = "--" + font_id
		elif font_id.length() == 2:
			font_id = "-" + font_id
	set_system_font(font_name)
	system_font_changed.emit(font_id)


func set_system_font(font_name : String):
	var font_name_array : PackedStringArray = [font_name]
	editor_font.font_names = font_name_array
