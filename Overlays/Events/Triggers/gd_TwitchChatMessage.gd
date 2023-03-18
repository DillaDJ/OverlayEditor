class_name TwitchChatMessage


var user : String
var msg : String


func _init(unprocessed_message):
	msg = unprocessed_message


func get_contents():
	return msg
