extends Button


@onready var message 	: Control = %Message
@onready var top_menu 	: Control = %TopMenu
@onready var change_mode: Control = %ChangeMode
@onready var right_panel: Control = %HierarchyInspector
@onready var bg_color 	: Control = %BGColorRect
@onready var gizmos 	: Control = %ToolGizmos
@onready var grid 		: Control = %Grid

var interface_hidden := false


func _ready():
	connect("button_down", Callable(self, "hide_interface"))


func _process(_delta):
	if interface_hidden and Input.is_anything_pressed():
		show_interface()
	
	elif !interface_hidden:
		if Input.is_action_just_pressed("alt"):
			hide_for_editing()
		elif Input.is_action_just_released("alt"):
			show_interface()


func hide_interface():
	message.show_message("Interface Hidden", "To unhide the interface, press any key after this message fades out")
	change_mode.hide()
	top_menu.hide()
	right_panel.hide()
	bg_color.hide()
	gizmos.hide()
	grid.hide()
	
	await get_tree().create_timer(3.5).timeout
	interface_hidden = true


func show_interface():
	change_mode.show()
	top_menu.show()
	right_panel.show()
	bg_color.show()
	gizmos.show()
	
	if %Grid.is_visible:
		grid.show()
	
	interface_hidden = false


func hide_for_editing():
	change_mode.hide()
	top_menu.hide()
	right_panel.hide()
