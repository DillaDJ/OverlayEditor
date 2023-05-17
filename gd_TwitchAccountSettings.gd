extends PanelContainer


@onready var default_user_texture : Texture2D = preload("res://Icons/profile-default.png")

@onready var link_btn 		: Button = $Layout/RightLayout/ConnectionLayout/LinkAccount
@onready var username 		: Label = $Layout/RightLayout/ConnectionLayout/Username
@onready var profile 		: TextureRect = $Layout/ProfilePicture


func _ready():
	link_btn.connect("button_down", Callable(self, "link_twitch_account"))
	sngl_Twitch.connect("twitch_account_linked", Callable(self, "display_user"))
	
	if sngl_Twitch.linked_account_data:
		display_user(sngl_Twitch.linked_account_data)


func link_twitch_account() -> void:
	if sngl_Twitch.linked_account_data:
		revoke_user_display()
		return
	
	sngl_Twitch.request_auth_code()


func display_user(data : Dictionary) -> void:
	link_btn.text = "Unlink"
	username.text = data["display_name"]
	
	sngl_Twitch.connect("image_data_parsed", Callable(self, "set_profile_pic"))
	sngl_Twitch.download_image(data["profile_image_url"])


func revoke_user_display() -> void:
	link_btn.text = "Link"
	username.text = "None"
	profile.texture = default_user_texture
	
	sngl_Twitch.clear_tokens()


func set_profile_pic(data : PackedByteArray) -> void:
	sngl_Twitch.disconnect("image_data_parsed", Callable(self, "set_profile_pic"))
	
	var image_to_load := Image.new()
	var load_error := image_to_load.load_jpg_from_buffer(data) # Try jpg
	
	# Try png
	if load_error:
		load_error = image_to_load.load_png_from_buffer(data)
		
	if load_error:
		printerr("Failed to load profile picture")
		return
	
	var image_texture := ImageTexture.create_from_image(image_to_load)
	profile.texture = image_texture
	return
