extends Overlay


func _ready() -> void:
	super()
	type = Type.GRID
	
	# Properties
	Property.create_formatting(overridable_properties)
	
	Property.create_write(overridable_properties, "Columns", TYPE_INT, Callable(self, "get_columns"), Callable(self, "set_columns"))
