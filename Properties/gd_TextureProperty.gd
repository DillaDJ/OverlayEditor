extends PropertyInterface


@onready var texture_rect 	: TextureRect = $VBoxContainer/PanelContainer/TextureRect
@onready var file_dialog 	: FileDialog = $FileDialog


func _ready():
	var transform_tool = sngl_Utility.get_scene_root().get_node("%TransformTool")
	
	$VBoxContainer/Button.connect("button_down", Callable(file_dialog, "popup"))
	$FileDialog.connect("file_selected", Callable(self, "load_texture"))
	$FileDialog.connect("visibility_changed", Callable(transform_tool, "toggle_enabled"))


func set_prop_value(new_texture) -> void:
	texture_rect.texture = new_texture


func load_texture(path : String) -> void:
	var image 	: Image = Image.load_from_file(path)
	var texture : ImageTexture = ImageTexture.create_from_image(image)
	set_prop_value(texture)
	
	emit_signal("value_changed", texture)
