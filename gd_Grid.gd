class_name Grid
extends Control

@export var primary_color 	: Color
@export var secondary_color : Color

var screen_dimensions

var x_increment
var y_increment

var grid_size : int = 5


func _ready():
	recalculate_grid()


func _process(delta):
	snap_to_nearest_point(Vector2.ZERO)


func _draw():
	var current_x = x_increment
	var current_y = y_increment
	var i = 0
	
	while(current_x < screen_dimensions.x):
		var x_from 	= Vector2(current_x, 0)
		var x_to 	= Vector2(current_x, screen_dimensions.y)
		current_x += x_increment
		
		if (i + 1) % grid_size == 0:
			draw_line(x_from, x_to, primary_color)
		else:
			draw_line(x_from, x_to, secondary_color)
		
		i += 1
	i = 0
	
	while(current_y < screen_dimensions.y):
		var y_from 	= Vector2(0, current_y)
		var y_to 	= Vector2(screen_dimensions.x, current_y)
		current_y += y_increment
		
		if (i + 1) % grid_size == 0:
			draw_line(y_from, y_to, primary_color)
		else:
			draw_line(y_from, y_to, secondary_color)
		
		i += 1


func recalculate_grid():
	screen_dimensions = get_viewport_rect().size
	
	x_increment = screen_dimensions.x / ((screen_dimensions.x / screen_dimensions.y) * pow(2, grid_size))
	y_increment = screen_dimensions.y / pow(2, grid_size)
	
	queue_redraw()


func set_grid_size(new_size):
	grid_size = new_size
	recalculate_grid()


func toggle_grid():
	if is_visible_in_tree():
		hide()
	else:
		show()


func snap_to_nearest_point(point : Vector2):
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()
	var x_pos = x_increment * round(mouse_pos.x / x_increment)
	var y_pos = y_increment * round(mouse_pos.y / y_increment)
	
	return Vector2(x_pos, y_pos)
