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
				latest_message = TwitchChatMessage.new(client.get_packet().get_string_from_utf8())
				triggered.emit()
		
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = client.get_close_code()
		var reason = client.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		poll_timer.stop()


func get_message_text() -> String:
	return latest_message.get_contents()
