class_name TwitchUser


var id : int
var login : String
var username : String
var chat_color : Color = Color.GHOST_WHITE
var profile_image_url : String

var user_setup := false

signal finished_setup()


func _init(user_login : String):
	login = user_login.to_lower()
	get_user_data(login)


func get_user_data(user_login : String) -> void:
	sngl_Twitch.request_user_data(user_login)
	sngl_Twitch.connect("user_data_parsed", Callable(self, "set_user_data"))


func set_user_data(data : Dictionary) -> void:
	sngl_Twitch.disconnect("user_data_parsed", Callable(self, "set_user_data"))
	
	id = int(data["id"])
	username = data["display_name"]
	profile_image_url = data["profile_image_url"]
	
	sngl_Twitch.request_user_chat_color(id)
	sngl_Twitch.connect("user_color_parsed", Callable(self, "set_chat_color"))


func get_chat_color() -> Color:
	return chat_color


func set_chat_color(data : Dictionary) -> void:
	var color : String = data["color"]
	
	if color == "":
		chat_color = Color.from_hsv(randf_range(0, 1), 0.8, 1.0)
	else:
		chat_color = Color(color)
	
	if !user_setup:
		sngl_Twitch.disconnect("user_color_parsed", Callable(self, "set_chat_color"))
		user_setup = true
		finished_setup.emit()
		

