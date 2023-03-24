extends Overlay


signal size_reset(texture_size : Vector2)
signal reset()


func _ready():
	super()
	
	overridable_properties.append(WriteProperty.new("Texture", 			Property.Type.TEXTURE, Callable(self, "get_texture"), Callable(self, "set_texture")))
	overridable_properties.append(WriteProperty.new("Region Position",	Property.Type.VECTOR2, Callable(self, "get_rect_pos"), Callable(self, "set_rect_pos")))
	overridable_properties.append(WriteProperty.new("Region Size", 		Property.Type.VECTOR2, Callable(self, "get_rect_size"), Callable(self, "set_rect_size")))
	
	overridable_properties.append(WriteProperty.new("Region Margin", 	Property.Type.VECTOR4, Callable(self, "get_region_margin"), Callable(self, "set_region_margin")))
	
	overridable_properties.append(WriteProperty.EnumProperty.new("Stretch Horizontal", ["Stretch", "Tile", "Tile Fit"], Callable(self, "get_h_stretch"), Callable(self, "set_h_stretch")))
	overridable_properties.append(WriteProperty.EnumProperty.new("Stretch Vertical", ["Stretch", "Tile", "Tile Fit"], Callable(self, "get_v_stretch"), Callable(self, "set_v_stretch")))
	overridable_properties.append(WriteProperty.new("Draw Center", 		Property.Type.BOOL, Callable(self, "get_b_draw_center"), Callable(self, "set_b_draw_center")))


func get_texture() -> Texture2D:
	return self.texture


func set_texture(texture : Texture2D):
	self.texture = texture
	reset_rect()


func get_b_draw_center() -> bool:
	return self.draw_center


func set_b_draw_center(value : bool) -> void:
	self.draw_center = value


func get_rect_pos() -> Vector2:
	var rect : Rect2 = self.region_rect
	return rect.position


func set_rect_pos(new_pos : Vector2) -> void:
	var rect : Rect2 = self.region_rect
	rect.position = new_pos
	self.region_rect = rect


func get_rect_size() -> Vector2:
	var rect : Rect2 = self.region_rect
	return rect.size


func set_rect_size(new_size : Vector2) -> void:
	var rect : Rect2 = self.region_rect
	rect.size = new_size
	self.region_rect = rect


func get_region_margin() -> Vector4:
	var margin = Vector4()
	
	margin.x = self.patch_margin_left
	margin.y = self.patch_margin_top
	margin.z = self.patch_margin_right
	margin.w = self.patch_margin_bottom
	
	return margin


func set_region_margin(margin : Vector4) -> void:
	self.patch_margin_left 		= margin.x
	self.patch_margin_top 		= margin.y
	self.patch_margin_right 	= margin.z
	self.patch_margin_bottom 	= margin.w


func get_h_stretch() -> int:
	return self.axis_stretch_horizontal as int


func set_h_stretch(new_value : int) -> void:
	self.axis_stretch_horizontal = new_value as NinePatchRect.AxisStretchMode


func get_v_stretch() -> int:
	return self.axis_stretch_vertical as int


func set_v_stretch(new_value : int) -> void:
	self.axis_stretch_vertical = new_value as NinePatchRect.AxisStretchMode


func reset_rect():
	var texture : ImageTexture = self.texture
	
	size_reset.emit(texture.get_size())
	reset.emit()
