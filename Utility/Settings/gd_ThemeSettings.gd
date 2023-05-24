extends VBoxContainer


@onready var base : Theme = preload("res://Utility/Appearance/Theme/thm_Base.tres")
@onready var font_settings 		: LabelSettings = preload("res://Utility/Appearance/thm_default_text.tres")
@onready var bold_font_settings : LabelSettings = preload("res://Utility/Appearance/thm_default_text_bold.tres")
@onready var theme_buttons := $ThemeButtons/HBoxContainer

# Color Buttons
@onready var primary_button 	: Button = $ThemeColors/Primary/ColorPickerButton
@onready var secondary_button 	: Button = $ThemeColors/Secondary/ColorPickerButton
@onready var tertiary_button 	: Button = $ThemeColors/Tertiary/ColorPickerButton
@onready var text_button 		: Button = $ThemeColors/Text/ColorPickerButton
@onready var button_button 		: Button = $ThemeColors/Button/ColorPickerButton
@onready var accent_button 		: Button = $ThemeColors/Accent/ColorPickerButton

# Primary
@onready var prim 				: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Primary.tres")
@onready var prim_nomarg 		: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Primary_marginless.tres")
@onready var prim_unrnd 		: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Primary_unrounded.tres")
@onready var prim_unrnd_exmarg 	: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Primary_unrounded_extramargin.tres")
@onready var prim_unrnd_no_marg : StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Primary_unrounded_marginless.tres")
@onready var expand_button 		: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Expand_Button.tres")
@onready var help_button 		: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_HelpButton.tres")
@onready var footer 			: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Footer.tres")
@onready var tab_selected 		: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Tab_selected.tres")
@onready var window 			: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Window.tres")

# Secondary
@onready var sec 				: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Secondary.tres")
@onready var sec_nomarg 		: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Secondary_marginless.tres")
@onready var sec_smmarg 		: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Secondary_smallmargin.tres")
@onready var sec_unrnd 			: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Secondary_unrounded.tres")
@onready var sec_unrnd_no_marg 	: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Secondary_unrounded_marginless.tres")
@onready var popup_menu 		: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_PopupMenu.tres")

# Tertiary
@onready var ter 				: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Tertiary.tres")
@onready var ter_unrnd 			: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Tertiary_unrounded.tres")

# Button
@onready var button				: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Button_normal.tres")
@onready var button_hover		: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Button_hover.tres")
@onready var button_pressed		: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Button_pressed.tres")
@onready var color_pick_btn		: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Color_picker_button_normal.tres")
@onready var color_pick_btn_hvr : StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Color_picker_button_hover.tres")

#Accent
@onready var header 			: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Header.tres")
@onready var resize 			: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Resize.tres")
@onready var selected_shaded	: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Selected_shaded.tres")
@onready var selected_unrnd 	: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Selected_unrounded.tres")
@onready var tree_selected 		: StyleBoxFlat = preload("res://Utility/Appearance/Theme/thm_Tree_selected.tres")

var is_using_custom_theme := false


signal preset_changed(idx : String)


func _ready():
	$ThemeColors/Primary/ColorPickerButton.connect("color_changed", Callable(self, "set_primary_color"))
	$ThemeColors/Primary/ColorPickerButton.connect("button_down", Callable(self, "toggle_custom").bind(true))
	$ThemeColors/Secondary/ColorPickerButton.connect("color_changed", Callable(self, "set_secondary_color"))
	$ThemeColors/Secondary/ColorPickerButton.connect("button_down", Callable(self, "toggle_custom").bind(true))
	$ThemeColors/Tertiary/ColorPickerButton.connect("color_changed", Callable(self, "set_tertiary_color"))
	$ThemeColors/Tertiary/ColorPickerButton.connect("button_down", Callable(self, "toggle_custom").bind(true))
	$ThemeColors/Text/ColorPickerButton.connect("color_changed", Callable(self, "set_text_color"))
	$ThemeColors/Text/ColorPickerButton.connect("button_down", Callable(self, "toggle_custom").bind(true))
	$ThemeColors/Button/ColorPickerButton.connect("color_changed", Callable(self, "set_button_color"))
	$ThemeColors/Button/ColorPickerButton.connect("button_down", Callable(self, "toggle_custom").bind(true))
	$ThemeColors/Accent/ColorPickerButton.connect("color_changed", Callable(self, "set_accent_color"))
	$ThemeColors/Accent/ColorPickerButton.connect("button_down", Callable(self, "toggle_custom").bind(true))
	
	var theme_presets = theme_buttons.get_children()
	for i in range(theme_buttons.get_child_count()):
		var theme_button : Button = theme_presets[i]
		theme_button.connect("button_down", Callable(self, "set_theme_preset").bind(i))
		theme_button.connect("button_down", Callable(self, "toggle_custom").bind(false))
	


func set_primary_color(new_color : Color):
	prim.bg_color 				= new_color
	prim_nomarg.bg_color		= new_color
	prim_unrnd.bg_color 		= new_color
	prim_unrnd_exmarg.bg_color 	= new_color
	prim_unrnd_no_marg.bg_color = new_color
	expand_button.bg_color 		= new_color
	help_button.bg_color		= new_color
	footer.bg_color 			= new_color
	tab_selected.bg_color 		= new_color
	window.bg_color 			= new_color


func set_secondary_color(new_color : Color):
	sec.bg_color 				= new_color
	sec_nomarg.bg_color			= new_color
	sec_unrnd.bg_color 			= new_color
	sec_smmarg.bg_color 		= new_color
	sec_unrnd_no_marg.bg_color 	= new_color
	popup_menu.bg_color 		= new_color


func set_tertiary_color(new_color : Color):
	ter.bg_color 		= new_color
	ter_unrnd.bg_color	= new_color


func set_text_color(new_color : Color):
	base.set_color("font_hover_color", "Button", new_color)
	base.set_color("font_focus_color", "Button", new_color)
	base.set_color("icon_hover_color", "Button", new_color)
	base.set_color("icon_hover_pressed_color", "Button", new_color)
	base.set_color("icon_focus_color", "Button", new_color)
	
	base.set_color("font_hover_color", "ToggleContentButton", new_color)
	base.set_color("font_focus_color", "ToggleContentButton", new_color)
	base.set_color("icon_hover_color", "ToggleContentButton", new_color)
	base.set_color("icon_focus_color", "ToggleContentButton", new_color)
	base.set_color("file_icon_color", "FileDialog", new_color)
	
	base.set_color("font_color", "CheckBox", new_color)
	base.set_color("font_color", "CheckButton", new_color)
	base.set_color("font_color", "ColorPickerButton", new_color)
	base.set_color("font_color", "Label", new_color)
	base.set_color("font_color", "LineEdit", new_color)
	base.set_color("font_color", "OptionButton", new_color)
	base.set_color("font_color", "PopupMenu", new_color)
	base.set_color("font_color", "TextEdit", new_color)
	base.set_color("font_selected_color", "Tree", new_color)
	base.set_color("font_selected_color", "TabContainer", new_color)
	base.set_color("title_color", "Window", new_color)
	
	var color_faded = new_color
	color_faded.a8 = 50
	base.set_color("icon_normal_color", "ToggleContentButton", color_faded)
	base.set_color("font_color", "ToggleContentButton", color_faded)
	
	color_faded.a8 = 100
	base.set_color("icon_disabled_color", "Button", color_faded)
	base.set_color("font_disabled_color", "Button", color_faded)
	
	color_faded.a8 = 180
	base.set_color("font_color", "Button", color_faded)
	base.set_color("icon_normal_color", "Button", new_color)
	base.set_color("font_unselected_color", "TabContainer", color_faded)
	base.set_color("font_color", "Tree", color_faded)
	base.set_color("folder_icon_color", "FileDialog", color_faded)
	
	popup_menu.border_color = new_color
	color_pick_btn.border_color = new_color
	bold_font_settings.font_color = new_color
	font_settings.font_color = new_color


func set_button_color(new_color : Color):
	button.bg_color = new_color
	
	new_color.v += 0.05
	button_hover.bg_color = new_color
	
	new_color.v -= 0.10
	button_pressed.bg_color = new_color


func set_accent_color(new_color : Color):
	header.bg_color = new_color
	resize.bg_color = new_color
	tab_selected.border_color = new_color
	window.border_color = new_color
	selected_shaded.border_color = new_color
	selected_unrnd.border_color = new_color
	color_pick_btn_hvr.border_color = new_color
	tree_selected.border_color = new_color
	
	var faded_color = new_color
	faded_color.a = .5
	tree_selected.bg_color = faded_color
	
	new_color.v += -0.1
	new_color.s += 0.05
	header.border_color = new_color
	
	base.set_color("icon_pressed_color", "Button", new_color)


func toggle_custom(using_custom : bool):
	if using_custom:
		for theme_button in theme_buttons.get_children():
			theme_button.set_pressed(false)
		$Name.text = "Selected Preset: Custom"
	
	is_using_custom_theme = using_custom


func set_theme_preset(idx : int):
	if theme_buttons.get_child(idx).is_pressed() or is_using_custom_theme:
		return
	
	var theme_button 		: Button = theme_buttons.get_child(idx)
	var primary_panel 		: Panel = theme_button.get_node("Theme/Primary")
	var secondary_panel 	: Panel = theme_button.get_node("Theme/VBoxContainer/Secondary")
	var tertiary_panel 		: Panel = theme_button.get_node("Theme/VBoxContainer/Tertiary")
	var text_label 			: Label = theme_button.get_node("Theme/Primary/Label")
	
	var primary 			: Color = primary_panel.get_theme_stylebox("panel").bg_color
	var secondary 			: Color = secondary_panel.get_theme_stylebox("panel").bg_color
	var tertiary 			: Color = tertiary_panel.get_theme_stylebox("panel").bg_color
	var text 				: Color = text_label.label_settings.font_color
	var button_color		: Color = secondary_panel.get_theme_stylebox("panel").border_color
	var accent 				: Color = theme_button.get_theme_stylebox("pressed").bg_color
	
	set_primary_color(primary)
	set_secondary_color(secondary)
	set_tertiary_color(tertiary)
	set_text_color(text)
	set_button_color(button_color)
	set_accent_color(accent)
	
	primary_button.color = primary
	secondary_button.color = secondary
	tertiary_button.color = tertiary
	text_button.color = text
	button_button.color = button_color
	accent_button.color = accent
	theme_button.set_pressed(true)
	
	$Name.text = "Selected Preset: %s" % theme_button.name
	preset_changed.emit("%d" % idx)
