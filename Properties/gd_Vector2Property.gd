extends PropertyInterface


@onready var x_coord = $CoordinateLayout/XCoords
@onready var y_coord = $CoordinateLayout/YCoords

var supress_signals := false


func _ready():
	x_coord.connect("value_changed", Callable(self, "set_prop_x"))
	y_coord.connect("value_changed", Callable(self, "set_prop_y"))


func set_prop_value(new_vector : Vector2) -> void:
	x_coord.value = new_vector.x
	y_coord.value = new_vector.y


func set_prop_x(new_x : float) -> void:
	x_coord.value = new_x
	
	if !supress_signals:
		emit_signal("value_changed", Vector2(x_coord.value, y_coord.value))


func set_prop_y(new_y : float) -> void:
	y_coord.value = new_y
	
	if !supress_signals:
		emit_signal("value_changed", Vector2(x_coord.value, y_coord.value))


func set_prop_value_suppressed(new_vector : Vector2) -> void:
	supress_signals = true
	
	x_coord.value = new_vector.x
	y_coord.value = new_vector.y
	
	supress_signals = false
