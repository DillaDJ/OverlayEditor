extends Button


@onready var grid_menu = $GridSettingsBG


func _ready():
	connect("toggled", Callable(self, "toggle_grid_menu"))
	$GridSettingsBG/FieldsLayout/ToggleGridLayout/CheckBox.connect("button_down", Callable(%Grid, "toggle_grid"))
	$GridSettingsBG/FieldsLayout/GridSnapLayout/CheckBox.connect("button_down", Callable(%Grid, "toggle_grid_snap"))
	$GridSettingsBG/FieldsLayout/GridSizeLayout/SpinBox.connect("value_changed", Callable(%Grid, "set_grid_size"))


func _input(event):
	if grid_menu.is_visible_in_tree() and event is InputEventMouseButton:
		if !get_global_rect().has_point(event.position) and !grid_menu.get_global_rect().has_point(event.position):
			set_pressed(false)
			grid_menu.hide()


func toggle_grid_menu(is_showing : bool):
	if is_showing:
		grid_menu.show()
	else:
		grid_menu.hide()
