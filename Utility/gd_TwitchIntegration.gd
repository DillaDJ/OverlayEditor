class_name TwitchIntegration
extends Node


const username 		:= "overlayeditor"
const password 		:= "yjy7v406y9y1fus4zkgdl5q9x6myd0"
const client_id		:= "zwna9fh0wp9wx5f8i6saxt7igx5wf5"
const client_secret	:= "wz5oyd785ppv1spw783lp6xaio63hw"

var connected_channels : Dictionary = {}
var http_request : HTTPRequest
var poll_timer : Timer


signal user_data_parsed(data)


func _ready() -> void:
	http_request = HTTPRequest.new()
	poll_timer = Timer.new()
	
	add_child(http_request)
	add_child(poll_timer)
	
	poll_timer.wait_time = 0.1
	
	http_request.connect("request_completed", Callable(self, "parse_request"))
	poll_timer.connect("timeout", Callable(self, "poll_channels"))
	
	poll_timer.start()
	
	#request_oauth_token("8swrkvp2kk92phpk1e44h5i7tuytsi")


func poll_channels() -> void:
	for channel in connected_channels:
		connected_channels[channel].poll()


func connect_to_channel(channel_name : String) -> TwitchChannelData:
	if !connected_channels.has(channel_name):
		connected_channels[channel_name] = TwitchChannelData.new(channel_name)
	
	return connected_channels[channel_name]


# HTTP Requests
func request_auth_code():
	var auth_url := "https://id.twitch.tv/oauth2/authorize
		?response_type=code
		&client_id=%s
		&redirect_uri=http://localhost:3000
		&scope=chat:read" % client_id
	
	OS.shell_open(auth_url)


func request_oauth_token(code : String):
	var param := "client_id=%s&client_secret=%s&code=%s&grant_type=authorization_code&redirect_uri=http://localhost:3000" % [client_id, client_secret, code]
	
	http_request.request("https://id.twitch.tv/oauth2/token", PackedStringArray(["Content-Type: application/x-www-form-urlencoded"]), 
						HTTPClient.METHOD_POST, param)


func request_user_data(login_name : String):
	http_request.request("https://api.twitch.tv/helix/users?login=%s" % login_name, \
	PackedStringArray(["Authorization: Bearer %s" % password, "Client-Id: %s" % client_id]))


func request_user_chat_color(user_id : int):
	http_request.request("https://api.twitch.tv/helix/chat/color?user_id=%d" % user_id, \
	PackedStringArray(["Authorization: Bearer %s" % password, "Client-Id: %s" % client_id]))


func parse_request(_result : int, response_code : int, _headers : PackedStringArray, body : PackedByteArray) -> void:
	match response_code:
		200:
			var data : Dictionary = JSON.parse_string(body.get_string_from_utf8())
			
			if data.has("data"):
				var parsed_data = data["data"][0]
				
				if parsed_data.has("display_name"):
					user_data_parsed.emit(parsed_data)
				elif parsed_data.has("color"):
					user_data_parsed.emit(parsed_data)
			
		400:
			printerr("400: " + body.get_string_from_utf8())
			
		401:
			printerr("401: " + body.get_string_from_utf8())

