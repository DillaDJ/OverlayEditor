extends Button


func _ready():
	connect("button_down", Callable(self, "show_grid_menu"))
	$GridSettingsBG/FieldsLayout/ToggleGridLayout/CheckBox.connect("button_down", Callable(%Grid, "toggle_grid"))
	$GridSettingsBG/FieldsLayout/GridSnapLayout/CheckBox.connect("button_down", Callable(%Grid, "toggle_grid_snap"))
	$GridSettingsBG/FieldsLayout/GridSizeLayout/SpinBox.connect("value_changed", Callable(%Grid, "set_grid_size"))


func show_grid_menu():
	var grid_menu = $GridSettingsBG
	
	if grid_menu.is_visible_in_tree():
		grid_menu.hide()
	else:
		grid_menu.show()
