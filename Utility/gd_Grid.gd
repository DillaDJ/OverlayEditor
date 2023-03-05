class_name OverlayGrid
extends Control

@export var primary_color 	: Color
@export var secondary_color : Color

const lowest_increment : int = 800

var screen_dimensions

var increment : int

var grid_size : int = 6

var is_visible := false


func _ready():
	get_viewport().connect("size_changed", Callable(self, "recalculate_grid"))
	recalculate_grid()


func _draw():
	var current_x := increment
	var current_y := increment
	var i : int = 0
	var j : int = 0
	
	while(current_x < screen_dimensions.x):
		var x_from 	= Vector2(current_x, 0)
		var x_to 	= Vector2(current_x, screen_dimensions.y)
		current_x += increment
		
		if (i + 1) % grid_size == 0:
			draw_line(x_from, x_to, primary_color)
		else:
			draw_line(x_from, x_to, secondary_color)
		i += 1
		
	while(current_y < screen_dimensions.y):
		var y_from 	= Vector2(0, current_y)
		var y_to 	= Vector2(screen_dimensions.x, current_y)
		current_y += increment

		if (j + 1) % grid_size == 0:
			draw_line(y_from, y_to, primary_color)
		else:
			draw_line(y_from, y_to, secondary_color)
		j += 1


func recalculate_grid():
	screen_dimensions = get_viewport_rect().size
	increment = lowest_increment / int(pow(2, grid_size))
	queue_redraw()


func set_grid_size(new_size):
	grid_size = new_size
	recalculate_grid()


func toggle_grid():
	if is_visible:
		is_visible = false
		hide()
	else:
		is_visible = true
		show()


func snap_to_nearest_point(point : Vector2):
	var x_pos = increment * round(point.x / increment)
	var y_pos = increment * round(point.y / increment)
	
	return Vector2(x_pos, y_pos)
