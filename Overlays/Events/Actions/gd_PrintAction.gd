class_name PrintAction
extends Action


var message := "Test"


func _init():
	type = Type.PRINT


func execute():
	print(message)


func change_message(new_message : String) -> void:
	message = new_message
