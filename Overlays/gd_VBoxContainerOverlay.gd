extends Overlay


func _ready() -> void:
	super()
	type = Type.VBOX
	
	# Properties
	EnumProperty.create_enum(overridable_properties, "Alignment", ["Begin", "Center", "End"], Callable(self, "get_alignment"), Callable(self, "set_alignment"))
