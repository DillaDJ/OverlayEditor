class_name TwitchChatTrigger
extends Trigger


const server 	:= "wss://irc-ws.chat.twitch.tv:443"
const password 	:= "oauth:ii1norl81sg2fmjwsk5korywtivqk9"
const username 	:= "OverlayEditor"

var channel := "#nukedboom"

var client : WebSocketPeer

var poll_timer : Timer
var connected := false

var latest_message : TwitchChatMessage

var finished_connecting := false


func _init():
	type = Type.TWITCH_CHAT
	
	client = WebSocketPeer.new()
	client.connect_to_url(server)
	
	poll_timer = Timer.new()
	poll_timer.wait_time = 0.1
	
	sngl_Utility.get_scene_root().add_child(poll_timer)
	poll_timer.connect("timeout", Callable(self, "poll"))
	poll_timer.start()


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		client.close()


func duplicate_trigger() -> Trigger:
	var duplicated_trigger = TwitchChatTrigger.new()
	return duplicated_trigger


func poll():
	client.poll()
	
	var state = client.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if !connected:
			client.send_text("PASS %s" % password)
			client.send_text("NICK %s" % username)
			client.send_text("JOIN %s" % channel)
			connected = true
		else:
			while client.get_available_packet_count():
				if finished_connecting:
					var message = client.get_packet().get_string_from_utf8()
					if message.split(" ")[0] == "PING":
						client.send_text("PONG :tmi.twitch.tv")
					else:
						latest_message = TwitchChatMessage.new(message)
						triggered.emit()
				else: 
					var message = client.get_packet().get_string_from_utf8()
					if message.split(":")[-1] == "End of /NAMES list\r\n":
						finished_connecting = true
		
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = client.get_close_code()
		var reason = client.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		print("Reconnecting...")
		
		client.connect_to_url(server)


func get_message_user() -> String:
	if !latest_message:
		return ""
	
	return latest_message.get_user()


func get_message_contents() -> String:
	if !latest_message:
		return ""
	
	return latest_message.get_contents()
