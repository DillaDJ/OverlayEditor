class_name TwitchChannelData


const server 	:= "wss://irc-ws.chat.twitch.tv:443"


var connected := false
var finished_connecting := false

var latest_message : TwitchChatMessage

var channel_name : String
var client : WebSocketPeer

var connected_users : Dictionary = {}

signal chat_message_recieved()


func _init(channel : String):
	channel_name = channel
	
	client = WebSocketPeer.new()
	client.connect_to_url(server)


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		client.close()


func poll():
	client.poll()
	
	var state = client.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if !connected:
			client.send_text("PASS oauth:%s" % sngl_Twitch.password)
			client.send_text("NICK %s" % sngl_Twitch.username)
			client.send_text("JOIN %s" % channel_name)
			connected = true
		else:
			while client.get_available_packet_count():
				if finished_connecting:
					var message = client.get_packet().get_string_from_utf8()
					
					if message.split(" ")[0] == "PING":
						client.send_text("PONG :tmi.twitch.tv")
						
					else:
						latest_message = TwitchChatMessage.new(message)
						
						var login = latest_message.get_user_login()
						if !connected_users.has(login):
							connected_users[login] = TwitchUser.new(login)
						
						chat_message_recieved.emit()
				else: 
					var message = client.get_packet().get_string_from_utf8()
					
					if message.split(":")[-1] == "End of /NAMES list\r\n":
						finished_connecting = true
		
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = client.get_close_code()
		var reason = client.get_close_reason()
		finished_connecting = false
		connected = false
		
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		print("Reconnecting...\n")
		
		client.connect_to_url(server)


