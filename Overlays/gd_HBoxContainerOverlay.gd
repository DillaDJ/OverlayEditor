extends Overlay


func _ready() -> void:
	super()
	type = Type.HBOX
	
	# Properties
	Property.create_formatting(overridable_properties)
	
	EnumProperty.create_enum(overridable_properties, "Alignment", ["Begin", "Center", "End"], Callable(self, "get_alignment"), Callable(self, "set_alignment"))
