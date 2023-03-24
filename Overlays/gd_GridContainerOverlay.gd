extends Overlay


func _ready() -> void:
	super()
	
	# Properties
	overridable_properties.append(WriteProperty.new("Columns", Property.Type.INT, Callable(self, "get_columns"), Callable(self, "set_columns")))

