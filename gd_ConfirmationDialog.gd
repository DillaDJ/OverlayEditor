class_name Confirmation
extends ConfirmationDialog


func prompt(new_title : String, message : String):
	title = new_title
	dialog_text = message
	popup()
