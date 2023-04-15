class_name TwitchChatTrigger
extends Trigger


var channel_data : TwitchChannelData


func _init():
	type = Type.TWITCH_CHAT
	
	connect_to_channel("#nukedboom")


func connect_to_channel(channel : String) -> void:
	channel_data = sngl_Twitch.connect_to_channel(channel)
	channel_data.connect("chat_message_recieved", Callable(self, "trigger"))


func get_message_user() -> String:
	if !channel_data or !channel_data.latest_message:
		return ""
	
	return channel_data.latest_message.get_user()


func get_message_user_color() -> Color:
	if !channel_data or !channel_data.latest_message:
		return Color.DEEP_PINK
	
	var user : String = channel_data.latest_message.get_user_login()
	if channel_data.connected_users.has(user):
		return channel_data.connected_users[user].get_chat_color()
	
	return Color.DEEP_PINK


func get_message_contents() -> String:
	if !channel_data or !channel_data.latest_message:
		return ""
	
	return channel_data.latest_message.get_contents()
