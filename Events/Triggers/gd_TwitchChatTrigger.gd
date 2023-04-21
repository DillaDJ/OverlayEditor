class_name TwitchChatTrigger
extends Trigger


var channel_data : TwitchChannelData


func _init():
	type = Type.TWITCH_CHAT
	connect_to_channel("binq7q")


func connect_to_channel(channel : String) -> void:
	channel_data = sngl_Twitch.connect_to_channel(channel)
	channel_data.connect("chat_message_recieved", Callable(self, "process_message"))


func process_message(message : TwitchChatMessage):
	var login = message.get_user_login()
	
	if !channel_data.connected_users.has(login):
		var user = TwitchUser.new(login)
		channel_data.connected_users[login] = user
		user.connect("finished_setup", Callable(self, "trigger"))
	
	elif !channel_data.connected_users[login].user_setup: 
		if !channel_data.is_connected("finished_setup", Callable(self, "trigger")):
			channel_data.connect("finished_setup", Callable(self, "trigger"))
	
	else:
		trigger()


func get_message_user() -> String:
	if !channel_data or !channel_data.latest_message:
		return ""
	
	return channel_data.latest_message.get_user()


func get_message_user_color() -> Color:
	if !channel_data or !channel_data.latest_message:
		return Color.DEEP_PINK
	
	var user_login : String = channel_data.latest_message.get_user_login()
	if channel_data.connected_users.has(user_login):
		var user : TwitchUser = channel_data.connected_users[user_login]
		return user.get_chat_color()
	
	return Color.DEEP_PINK


func get_message_contents() -> String:
	if !channel_data or !channel_data.latest_message:
		return ""
	
	return channel_data.latest_message.get_contents()
