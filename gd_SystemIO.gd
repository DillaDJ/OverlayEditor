extends Control


@onready var confirm_dialog : ConfirmationDialog = $ConfirmationDialog
@onready var file_dialog 	: FileDialog = $FileDialog
@onready var message 		: Control = $Message


signal confirmed()
signal unconfirmed()

signal file_selected(path : String)
signal file_cancelled()


func _ready():
	message.connect("message_expired", Callable(self, "hide"))
	
	confirm_dialog.connect("confirmed", Callable(self, "confirm"))
	confirm_dialog.connect("canceled", Callable(self, "unconfirm"))
	
	file_dialog.connect("file_selected", Callable(self, "file_confirmed"))
	file_dialog.connect("canceled", Callable(self, "cancel_file"))


# System Message
func display_message(title, subtitle):
	show()
	message.title.text = title
	message.subtitle.text = subtitle
	
	message.anim.play("fadeinout")


# Confirmation Dialog
func prompt_confirmation(title : String, popup_message : String):
	confirm_dialog.title = title
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
func prompt_save_file():
	file_dialog.set_file_mode(FileDialog.FILE_MODE_SAVE_FILE)
	file_dialog.ok_button_text = "Save"
	
	file_dialog.filters.clear()
	file_dialog.position = (Vector2i(get_viewport_rect().size) - file_dialog.size) / 2.0
	
	file_dialog.popup()
	show()


func prompt_load_file(filters : Array[String] = []):
	file_dialog.set_file_mode(FileDialog.FILE_MODE_OPEN_FILE)
	file_dialog.ok_button_text = "Load"
	
	file_dialog.filters = filters
	file_dialog.position = (Vector2i(get_viewport_rect().size) - file_dialog.size) / 2.0
	
	file_dialog.popup()
	show()


func file_confirmed(path : String):
	file_selected.emit(path)
	hide()


func cancel_file():
	file_cancelled.emit()
	hide()
