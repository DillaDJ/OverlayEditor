extends Overlay


var channel_login = "binq7q"


func _ready():
	Property.create_write(overridable_properties, "Twitch Chat Text", TYPE_STRING_NAME, Callable(self, "get_text"), Callable(self, "set_text_as_twitch_chat"))
	
	Property.create_write(overridable_properties, "Text Size", TYPE_INT, Callable(self, "get_text_size"), Callable(self, "set_text_size"))


func get_text() -> String:
	return self.text


func get_text_as_twitch_chat() -> String:
	return ""


func set_text_as_twitch_chat(value : String):
	if sngl_Twitch.connected_channels.has(channel_login):
		var channel : TwitchChannelData = sngl_Twitch.connected_channels[channel_login]
		Callable(self, "clear").call()
		
		for word in value.split(" "):
			var emote : TwitchEmote = channel.find_emote(word)
			if emote == null:
				Callable(self, "add_text").call(word + " ")
				continue
			
			var img_size = get_text_size()
			var image_res = 0
			if img_size > 30:
				image_res = 2 if img_size > 60 else 1
			emote.start_load_image(image_res)
			
			if !emote.image_loaded:
				await emote.image_finished_loading
			# (image: Texture2D, width: int = 0, height: int = 0, color: Color = Color(1, 1, 1, 1), inline_align: InlineAlignment = 5, region: Rect2 = Rect2(0, 0, 0, 0))
			Callable(self, "add_image").call(emote.image, img_size, img_size, Color.WHITE, INLINE_ALIGNMENT_CENTER)
		
		self.text = self.text.strip_edges()


func get_text_size() -> int:
	return get_theme_font_size("normal_font_size")

func set_text_size(new_size):
	add_theme_font_size_override("normal_font_size", new_size)
