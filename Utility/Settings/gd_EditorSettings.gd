extends Control


const current_version := "v0.13"
const settings_path := "user://settings.cfg"

var tutorial_disabled := false

@onready var account_settings := $VerticalLayout/TabContainer/General/VerticalLayout/TwitchLogin
@onready var theme_settings := $VerticalLayout/TabContainer/Appearance/VerticalLayout/Theme
@onready var font_settings := $VerticalLayout/TabContainer/Appearance/VerticalLayout/EditorFont


func _ready() -> void:
	%Help/Close.connect("button_down", Callable(self, "disable_tutorial"))
	$Close.connect("button_down", Callable(self, "finalize_settings"))
	
	theme_settings.connect("preset_changed", Callable(self, "write_line_in_cfg").bind(2))
	font_settings.connect("system_font_changed", Callable(self, "write_line_in_cfg").bind(3))
	
	load_settings()


func disable_tutorial() -> void:
	if !tutorial_disabled:
		write_line_in_cfg("0", 1)


# Config
func init_settings():
	var file = FileAccess.open(settings_path, FileAccess.WRITE)
	file.store_line(current_version)
	file.store_line("1")		# Tutorial
	file.store_line("1")		# Theme
	file.store_line("---")		# Font
	file.store_line("0")		# Menu Side
	file.close()
	
	%Help.show()


func load_settings():
	if FileAccess.file_exists(settings_path):
		var file = FileAccess.open(settings_path, FileAccess.READ)
		var settings : Array[String] = []
		
		while !file.eof_reached():
			settings.append(file.get_line())
		
		if settings[0] != current_version:
			init_settings()
			return
		
		if settings[1] == "0":
			tutorial_disabled = true
			%Help.hide()
		else:
			%Help.show()
		
		if settings[2] != "0":
			theme_settings.set_theme_preset(settings[2].to_int() - 1)
		
		font_settings.load_font_from_cfg(settings[3])
		
		file.close()
	else:
		init_settings()


func finalize_settings():
	hide()


# Utility
func write_line_in_cfg(contents : String, line_num : int):
	var file = FileAccess.open(settings_path, FileAccess.READ_WRITE)
	for i in range(line_num):
		file.get_line()
	file.store_line(contents)
	file.close()
