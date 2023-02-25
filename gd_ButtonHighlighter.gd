extends VBoxContainer

@export var base_stylebox : StyleBoxFlat
@export var highlighted_color : Color

var last_clicked : Button
var old_color : Color


func _ready():
	for button in get_children():
		if button.is_class("Button"):
			button.connect("button_down", Callable(self, "highlight_button").bind(button))


func highlight_button(clicked_button : Button):
	var clicked_stylebox = get_stylebox(clicked_button)
	old_color = clicked_stylebox.bg_color
	clicked_stylebox.bg_color = highlighted_color
	
	if last_clicked:
		var stylebox = get_stylebox(last_clicked)
		stylebox.bg_color = old_color
		
	last_clicked = clicked_button


func get_stylebox(node):
	var stylebox
	
	if node.has_theme_stylebox_override("normal"):
		stylebox = node.get_theme_stylebox("normal")
	else:
		stylebox = base_stylebox.duplicate()
		node.add_theme_stylebox_override("normal", stylebox)
	
	return stylebox
