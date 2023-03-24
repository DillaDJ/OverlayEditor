extends Overlay


func _ready() -> void:
	super()
	
	# Properties
	overridable_properties.append(WriteProperty.EnumProperty.new("Alignment", ["Begin", "Center", "End"], Callable(self, "get_alignment"), Callable(self, "set_alignment")))


