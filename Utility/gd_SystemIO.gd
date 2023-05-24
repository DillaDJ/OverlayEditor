class_name SystemIO
extends Panel


@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var title 		: Label = $MessageLayout/Title
@onready var subtitle 	: Label = $MessageLayout/Subtitle

var confirm_dialog 	: ConfirmationDialog
var file_dialog 	: FileDialog


signal message_expired()

signal confirmed()
signal unconfirmed()

signal file_selected(path : String)
signal file_cancelled()


func _ready():
	connect("message_expired", Callable(self, "hide"))
	
	create_confirm_dialogue()
	confirm_dialog.connect("confirmed", Callable(self, "confirm"))
	confirm_dialog.connect("canceled", Callable(self, "unconfirm"))
	
	create_file_dialogue()
	file_dialog.connect("file_selected", Callable(self, "file_confirmed"))
	file_dialog.connect("canceled", Callable(self, "cancel_file"))


# System Message
func display_message(new_subtitle : String, new_title : String) -> void: # Ordered to preserve title when using bind()
	title.text = new_title
	subtitle.text = new_subtitle
	show()
	
	anim.play("fadeinout")


func finish_fade():
	message_expired.emit()


# Confirmation Dialog
func create_confirm_dialogue():
	if confirm_dialog == null:
		confirm_dialog = ConfirmationDialog.new()
		get_tree().root.add_child(confirm_dialog)
		
		confirm_dialog.get_cancel_button().set_custom_minimum_size(Vector2(80, 30))
		confirm_dialog.get_ok_button().set_custom_minimum_size(Vector2(80, 30))
		
		confirm_dialog.set_theme(load("res://Utility/Appearance/Theme/thm_Base.tres"))


func prompt_confirmation(new_title : String, popup_message : String):
	confirm_dialog.title = new_title
	confirm_dialog.dialog_text = popup_message
	
	confirm_dialog.position = (Vector2i(get_viewport_rect().size) - confirm_dialog.size) / 2.0
	
	confirm_dialog.popup()


func confirm():
	confirmed.emit()
	hide()


func unconfirm():
	unconfirmed.emit()
	hide()


# File dialog
func create_file_dialogue():
	if file_dialog == null:
		file_dialog = FileDialog.new()
		get_tree().root.add_child(file_dialog)
		
		file_dialog.set_access(FileDialog.ACCESS_FILESYSTEM)
		
		file_dialog.size = Vector2i(800, 600)
		file_dialog.position = (Vector2i(get_viewport_rect().size) - file_dialog.size) / 2.0
		
		file_dialog.set_theme(load("res://Utility/Appearance/Theme/thm_Base.tres"))


func prompt_save_file(new_title = "Save a File"):
	file_dialog.set_file_mode(FileDialog.FILE_MODE_SAVE_FILE)
	file_dialog.clear_filters()
	
	file_dialog.ok_button_text = "Save"
	file_dialog.title = new_title
	
	file_dialog.popup()


func prompt_load_file(filters : Array[String] = [], new_title = "Open a File"):
	file_dialog.set_file_mode(FileDialog.FILE_MODE_OPEN_FILE)
	file_dialog.ok_button_text = "Load"
	file_dialog.filters = filters
	file_dialog.title = new_title
	
	file_dialog.popup()


func file_confirmed(path : String):
	file_selected.emit(path)


func cancel_file():
	file_cancelled.emit()
