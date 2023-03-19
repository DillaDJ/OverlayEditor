class_name TwitchChatMessage


var user : String
var msg : String
var raw_msg : String


func _init(unprocessed_message : String):
	raw_msg = unprocessed_message
	
	var split = unprocessed_message.split(":")
	user = split[1].split(" ")[2].lstrip("#")
	msg = split[2].lstrip(":")


func get_user():
	return user

func get_contents():
	return msg
