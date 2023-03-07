extends PropertyInterface


@onready var x_coord = $CoordinateLayout/XLayout/XCoords
@onready var y_coord = $CoordinateLayout/YLayout/YCoords
@onready var z_coord = $CoordinateLayout/ZLayout/ZCoords
@onready var w_coord = $CoordinateLayout/WLayout/WCoords


func _ready():
	x_coord.connect("value_changed", Callable(self, "set_property").bind(x_coord))
	y_coord.connect("value_changed", Callable(self, "set_property").bind(y_coord))
	z_coord.connect("value_changed", Callable(self, "set_property").bind(z_coord))
	w_coord.connect("value_changed", Callable(self, "set_property").bind(w_coord))


func set_prop_value(new_vector : Vector4) -> void:
	x_coord.value = new_vector.x
	y_coord.value = new_vector.y
	z_coord.value = new_vector.z
	w_coord.value = new_vector.w


func set_property(new_value : float, coord : SpinBox) -> void:
	coord.value = new_value
	
	emit_signal("value_changed", Vector4(x_coord.value, y_coord.value, z_coord.value, w_coord.value))
