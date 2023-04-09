extends PropertyInterface


@onready var texture_rect 	: TextureRect = $VBoxContainer/PanelContainer/TextureRect
@onready var file_io = sngl_Utility.get_scene_root().get_node("%System")


func _ready():
	$VBoxContainer/Button.connect("button_down", Callable(self, "get_texture_to_load"))


func set_prop_value(new_texture) -> void:
	texture_rect.texture = new_texture


func get_texture_to_load():
	var filters : Array[String] = ["*.png", "*.jpeg", "*.jpg"]
	file_io.connect("file_selected", Callable(self, "load_texture"))
	file_io.connect("file_cancelled", Callable(self, "cancel_load_texture"))
	
	file_io.prompt_load_file(filters)


func cancel_load_texture():
	file_io.disconnect("file_selected", Callable(self, "load_texture"))
	file_io.disconnect("file_cancelled", Callable(self, "cancel_load_texture"))


func load_texture(path : String) -> void:
	var image 	: Image = Image.load_from_file(path)
	var texture : ImageTexture = ImageTexture.create_from_image(image)
	set_prop_value(texture)
	cancel_load_texture()
	
	emit_signal("value_changed", texture)
