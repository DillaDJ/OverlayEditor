class_name TwitchEmote

enum Type { STATIC, ANIMATED }
const sizes = ["1.0", "2.0", "3.0"]
const image_cache_path := "user://cache/emotes/"

var name : String = ""
var type := Type.STATIC
var url_base := ""

var image : Texture2D
var image_loaded := false
var loaded_size := -1

signal image_finished_loading()


func _init(emote_data : Dictionary):
	name = emote_data["name"]
	
	if emote_data["format"].size() > 1:
		type = Type.ANIMATED

	var url : String = emote_data["images"]["url_1x"]
	if type == Type.ANIMATED:
		url = url.replace("/static/", "/animated/")
		
	url_base = url.substr(0, url.length() - 3)


func _to_string() -> String:
	return name


func start_load_image(size : int = 0):
	var path := "%s%s%s.png" % [image_cache_path, name, size + 1] if type == Type.STATIC else "%s%s%s.tres" % [image_cache_path, name, size + 1]
	
	if !FileAccess.file_exists(path):
		image_loaded = false
		sngl_Twitch.download_image(url_base + sizes[size])
		if type == Type.STATIC and !sngl_Twitch.is_connected("image_data_parsed", Callable(self, "save_animated_image_to_cache")):
			sngl_Twitch.connect("image_data_parsed", Callable(self, "save_image_to_cache").bind(path))
		elif !sngl_Twitch.is_connected("image_data_parsed", Callable(self, "save_animated_image_to_cache")):
			sngl_Twitch.connect("image_data_parsed", Callable(self, "save_animated_image_to_cache").bind(path))
		return
		
	if !image_loaded or size != loaded_size:
		loaded_size = size
		
		if type == Type.STATIC: 
			load_image(path)
		else:
			load_animated_image(path)


func save_image_to_cache(data : PackedByteArray, path : String):
	sngl_Twitch.disconnect("image_data_parsed", Callable(self, "save_image_to_cache"))
	
	if !DirAccess.dir_exists_absolute(image_cache_path):
		var dir_error := DirAccess.make_dir_recursive_absolute(image_cache_path)
		if dir_error:
			printerr("Failed to create emote directory")
	
	var image_to_load := Image.new()
	var load_error := image_to_load.load_png_from_buffer(data)
	
	if !load_error:
		var save_error := image_to_load.save_png(path)
		if save_error:
			printerr("Failed to save emote")
		
		var image_texture := ImageTexture.create_from_image(image_to_load)
		image = image_texture
		image_finished_loading.emit()
		
		sngl_Twitch.disconnect("image_data_parsed", Callable(self, "save_image_to_cache"))
		return
	
	printerr("Failed to load emote")


func save_animated_image_to_cache(data : PackedByteArray, path : String) -> void:
	if !gif.is_valid(data):
		return
	
	var dimensions 	:= gif.get_dimensions(data)
	var colors 		:= gif.get_color_table(data)
	var frame_data 	:= gif.split_into_frames(data)
	var anim := gif.get_anim_from_frame_data(frame_data, dimensions, colors)
	ResourceSaver.save(anim, path)
	image = anim

	sngl_Twitch.disconnect("image_data_parsed", Callable(self, "save_animated_image_to_cache"))

	image_loaded = true
	image_finished_loading.emit()


func load_image(path : String):
	var image_to_load : Image = Image.load_from_file(path)
	image = ImageTexture.create_from_image(image_to_load)
	
	sngl_Twitch.disconnect("image_data_parsed", Callable(self, "save_image_to_cache"))
	
	image_loaded = true
	image_finished_loading.emit()


func load_animated_image(path : String):
	var texture_to_load : AnimatedTexture = load(path)
	image = texture_to_load
	
	image_loaded = true
	image_finished_loading.emit()
