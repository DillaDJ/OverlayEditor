class_name TwitchChatMessage


var user_login_name : String
var msg : String
var raw_msg : String


func _init(unprocessed_message : String):
	raw_msg = unprocessed_message
	
	var regex := RegEx.new()
	regex.compile(":([^!]*).*PRIVMSG #[^ ]* :(.*)")
	
	var result := regex.search(unprocessed_message)
	
	if result.get_group_count() > 1:
		user_login_name = result.strings[1]
		msg = result.strings[2]


func get_user_login():
	return user_login_name


func get_contents():
	return msg
