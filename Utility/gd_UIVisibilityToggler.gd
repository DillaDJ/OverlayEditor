extends Button


@onready var message 	: Control = %Message
@onready var interface 	: Control = %Interface
@onready var bg_color 	: Control = %BGColorRect
@onready var gizmos 	: Control = %ToolGizmos
@onready var grid 		: Control = %Grid

var interface_hidden := false


func _ready():
	connect("button_down", Callable(self, "hide_interface"))


func _process(_delta):
	if interface_hidden and Input.is_anything_pressed():
		interface.show()
		bg_color.show()
		gizmos.show()
		
		if %Grid.is_visible:
			grid.show()
	
		interface_hidden = false


func hide_interface():
	message.show_message("Interface Hidden", "To unhide the interface, press any key after this message fades out")
	interface.hide()
	bg_color.hide()
	gizmos.hide()
	grid.hide()
	
	await get_tree().create_timer(3.5).timeout
	
	interface_hidden = true
