class_name TwitchChannelData


const server 	:= "ws://irc-ws.chat.twitch.tv:80"

var client : WebSocketPeer

var parameters_sent := false
var connected := false

var broadcaster : TwitchUser
var latest_message : TwitchChatMessage

var channel_emotes : Array = []
var connected_users : Dictionary = {}


signal chat_message_recieved(message : TwitchChatMessage)


func _init(channel_name : String):
	broadcaster = TwitchUser.new(channel_name)
	
	broadcaster.connect("finished_setup", Callable(self, "get_channel_emotes"))
	
	client = WebSocketPeer.new()
	client.connect_to_url(server)


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		client.close()


func poll():
	client.poll()
	
	var state = client.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if !parameters_sent:
			client.send_text("PASS oauth:%s" % sngl_Twitch.access_token)
			client.send_text("NICK %s" % sngl_Twitch.username)
			client.send_text("JOIN #%s" % broadcaster.login)
			parameters_sent = true
		else:
			while client.get_available_packet_count():
				var message = client.get_packet().get_string_from_utf8()
				# print(message) # Debug
				
				if connected:
					if message.split(" ")[0] == "PING":
						client.send_text("PONG :tmi.twitch.tv")

					else:
						latest_message = TwitchChatMessage.new(message)
						chat_message_recieved.emit(latest_message)
				else: 
					if message.split(":")[-1] == "End of /NAMES list\r\n":
						connected = true
		
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = client.get_close_code()
		var reason = client.get_close_reason()
		parameters_sent = false
		connected = false
		
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		print("Reconnecting...\n")
		
		client.connect_to_url(server)


func get_channel_emotes() -> void:
	broadcaster.disconnect("finished_setup", Callable(self, "get_channel_emotes"))
	sngl_Twitch.connect("emote_data_parsed", Callable(self, "add_channel_emotes"))
	sngl_Twitch.request_channel_emotes(broadcaster.id)


func add_channel_emotes(emote_data : Array) -> void:
	sngl_Twitch.disconnect("emote_data_parsed", Callable(self, "add_channel_emotes"))
	for emote in emote_data:
		var new_emote := TwitchEmote.new(emote)
		channel_emotes.append(new_emote)
	
	channel_emotes.sort_custom(func(a : TwitchEmote, b : TwitchEmote): return a.name < b.name)


func find_emote(emote_name : String) -> TwitchEmote:
	var bsort_func = func(array_element : TwitchEmote, search_str: String): return array_element.name < search_str
	var index = channel_emotes.bsearch_custom(emote_name, bsort_func)
	
	if index > channel_emotes.size() - 1:
		return null
	return channel_emotes[index]
