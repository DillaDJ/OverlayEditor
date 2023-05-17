class_name TwitchIntegration
extends Node


const username 		:= "overlayeditor"
const client_id		:= "zwna9fh0wp9wx5f8i6saxt7igx5wf5"
const client_secret	:= "wz5oyd785ppv1spw783lp6xaio63hw"
const token_path 	:= "user://token"

var access_token	:= ""
var refresh_token	:= ""
var linked_account_data : Dictionary = {}

var connected_channels : Dictionary = {}
var http_requests : Array[HTTPRequest]
var poll_timer : Timer

var expecting_uri_response := false


signal auth_token_parsed(data)
signal user_data_parsed(data)
signal user_color_parsed(data)
signal emote_data_parsed(data)
signal image_data_parsed(data)

signal twitch_account_linked(data)


func _ready() -> void:
	AppProtocol.connect("on_url_received", Callable(self, "request_oauth_token"))
	
	poll_timer = Timer.new()
	add_child(poll_timer)
	poll_timer.connect("timeout", Callable(self, "poll_channels"))
	poll_timer.wait_time = 0.1
	poll_timer.start()
	
	load_tokens()
	#request_oauth_token("code=eci2v72la324ne0wyf8xizgg1r3w1e&scope=chat%3Aread")


func spawn_http_request() -> HTTPRequest:
	var http_request = HTTPRequest.new()
	http_requests.append(http_request)
	add_child(http_request)
	
	return http_request


func despawn_http_request(http_request : HTTPRequest) -> void:
	http_requests.erase(http_request)
	http_request.queue_free()


# Channels
func poll_channels() -> void:
	if expecting_uri_response:
		AppProtocol.poll_server()
	
	for channel in connected_channels:
		connected_channels[channel].poll()


func connect_to_channel(channel_name : String) -> TwitchChannelData:
	channel_name = channel_name.to_lower()
	
	if !connected_channels.has(channel_name):
		connected_channels[channel_name] = TwitchChannelData.new(channel_name)
	
	return connected_channels[channel_name]


func get_channel_from_last_message(value : String) -> String:
	for channel in connected_channels:
		if connected_channels[channel].latest_message.get_contents() == value:
			return channel
	return ""


# Tokens
func load_tokens() -> void:
	var file : FileAccess 
	if FileAccess.file_exists(token_path):
		file = FileAccess.open(token_path, FileAccess.READ_WRITE)
	else:
		file = FileAccess.open(token_path, FileAccess.WRITE)
	
	if file == null:
		printerr("COULD NOT OPEN TOKENS")
	elif file.get_length() != 0:
		access_token = file.get_line().strip_edges()
		refresh_token = file.get_line().strip_edges()
		verify_tokens()
	file.close()


func save_tokens(data : Dictionary) -> void:
	var file := FileAccess.open(token_path, FileAccess.WRITE)
	access_token = data["access_token"]
	refresh_token = data["refresh_token"]
	
	if file == null:
		printerr("COULD NOT SAVE TOKENS")
	else:
		file.store_line(access_token)
		file.store_string(refresh_token)
	file.close()
	
	verify_tokens()


func clear_tokens() -> void:
	var file := FileAccess.open(token_path, FileAccess.WRITE)
	
	if file == null:
		printerr("COULD NOT CLEAR TOKENS")
	else:
		file.store_string("")
	file.close()


func verify_tokens() -> void:
	if access_token.length() != 30:
		refresh_oauth_token()
		return
	elif refresh_token.length() != 50:
		return
	
	request_app_user_data()


# Authentication HTTP Requests
func request_auth_code() -> void:
	var auth_url := "https://id.twitch.tv/oauth2/authorize
		?response_type=code
		&client_id=%s
		&redirect_uri=https://dilladj.github.io/OverlayRedirect/
		&scope=chat:read" % client_id
	expecting_uri_response = true
	OS.shell_open(auth_url)


func request_oauth_token(code_response : String) -> void:
	var code_field : String = code_response.split("&")[0]
	
	if code_field.begins_with("code="):
		var http := spawn_http_request()
		http.connect("request_completed", Callable(self, "parse_http_response_data").bind(http, ResponseType.AUTH_CODE))
		
		var code := code_field.right(code_field.length() - 5)
		var param := "client_id=%s&client_secret=%s&code=%s&grant_type=authorization_code&redirect_uri=https://dilladj.github.io/OverlayRedirect/" % [client_id, client_secret, code]
		http.request("https://id.twitch.tv/oauth2/token", PackedStringArray(["Content-Type: application/x-www-form-urlencoded"]), 
						HTTPClient.METHOD_POST, param)
		expecting_uri_response = false


func refresh_oauth_token() -> void:
	var http := spawn_http_request()
	http.connect("request_completed", Callable(self, "parse_http_response_data").bind(http, ResponseType.AUTH_REFRESH))
	
	var param := "grant_type=refresh_token&refresh_token=%s&client_id=%s&client_secret=%s&redirect_uri==https://dilladj.github.io/OverlayRedirect/" % [refresh_token, client_id, client_secret]
	http.request("https://id.twitch.tv/oauth2/token", PackedStringArray(["Content-Type: application/x-www-form-urlencoded"]), 
						HTTPClient.METHOD_POST, param)


# Other HTTP Requests
func request_app_user_data() -> void:
	var http := spawn_http_request()
	http.connect("request_completed", Callable(self, "parse_http_response_data").bind(http, ResponseType.APP_USER_DATA))
	
	http.request("https://api.twitch.tv/helix/users", \
	PackedStringArray(["Authorization: Bearer %s" % access_token, "Client-Id: %s" % client_id]))


func request_user_data(login_name : String) -> void:
	var http := spawn_http_request()
	http.connect("request_completed", Callable(self, "parse_http_response_data").bind(http, ResponseType.USER_DATA))
	
	http.request("https://api.twitch.tv/helix/users?login=%s" % login_name, \
	PackedStringArray(["Authorization: Bearer %s" % access_token, "Client-Id: %s" % client_id]))


func request_user_chat_color(user_id : int) -> void:
	var http := spawn_http_request()
	http.connect("request_completed", Callable(self, "parse_http_response_data").bind(http, ResponseType.COLOR_DATA))
	
	http.request("https://api.twitch.tv/helix/chat/color?user_id=%d" % user_id,
	PackedStringArray(["Authorization: Bearer %s" % access_token, "Client-Id: %s" % client_id]))


func request_global_emotes():
	var http := spawn_http_request()
	http.request("https://api.twitch.tv/helix/chat/emotes/global",
	PackedStringArray(["Authorization: Bearer %s" % access_token, "Client-Id: %s" % client_id]))


func request_channel_emotes(broadcaster_id : int) -> void:
	var http := spawn_http_request()
	http.connect("request_completed", Callable(self, "parse_http_response_data").bind(http, ResponseType.EMOTE))
	
	http.request("https://api.twitch.tv/helix/chat/emotes?broadcaster_id=%d" % broadcaster_id,
	PackedStringArray(["Authorization: Bearer %s" % access_token, "Client-Id: %s" % client_id]))


func download_image(url : String) -> void:
	var http := spawn_http_request()
	http.connect("request_completed", Callable(self, "parse_http_response_data").bind(http, ResponseType.IMAGE))
	http.request(url)


# Parse HTTP responses
enum ResponseType { AUTH_CODE, AUTH_REFRESH, APP_USER_DATA, USER_DATA, COLOR_DATA, EMOTE, IMAGE }
func validate_http_response(response_code : int, body : PackedByteArray) -> bool:
	if response_code == 200:
		return true
		
	elif response_code != 404:
		printerr("%d: %s" % [response_code, body.get_string_from_utf8()])
	
	else:
		printerr("404: Not Found")
	
	return false


func parse_http_response_data(_result : int, response_code : int, _headers : PackedStringArray, body : PackedByteArray, http_request : HTTPRequest, type : ResponseType) -> void:
	if validate_http_response(response_code, body):
		if type == ResponseType.IMAGE:
			image_data_parsed.emit(body)
			return
		
		var data : Dictionary = JSON.parse_string(body.get_string_from_utf8())
		
		match type:
			ResponseType.AUTH_CODE:
				save_tokens(data)
			
			ResponseType.AUTH_REFRESH:
				save_tokens(data)
			
			ResponseType.APP_USER_DATA:
				linked_account_data = data["data"][0]
				twitch_account_linked.emit(data["data"][0])
				
			ResponseType.USER_DATA:
				user_data_parsed.emit(data["data"][0])
			
			ResponseType.COLOR_DATA:
				user_color_parsed.emit(data["data"][0])
			
			ResponseType.EMOTE:
				emote_data_parsed.emit(data["data"])
			
			_:
				print(data)
	
	# Failed requests
	else:
		var response : Dictionary = JSON.parse_string(body.get_string_from_utf8())
		
		if response.has("message"):
			if response["message"] == "Invalid OAuth token":
				refresh_oauth_token()
			elif response["message"] == "Invalid refresh token":
				pass
	
	despawn_http_request(http_request)
