extends Overlay


func _ready():
	super()
	
	# Properties
	overridable_properties.append(Property.new("Color", Property.Type.COLOR, Callable(self, "get_overlay_color"), Callable(self, "set_overlay_color")))


func get_overlay_color():
	var stylebox : StyleBoxFlat = get_stylebox()
	return stylebox.bg_color


func set_overlay_color(new_color):
	var stylebox : StyleBoxFlat = get_stylebox()
	stylebox.bg_color = new_color


func get_stylebox() -> StyleBoxFlat:
	var stylebox

	if has_theme_stylebox_override("panel"):
		stylebox = get_theme_stylebox("panel")
	else:
		stylebox = StyleBoxFlat.new()
		add_theme_stylebox_override("panel", stylebox)

	return stylebox
