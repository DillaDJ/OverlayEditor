class_name WaitAction
extends Action


@export var wait_time = 1.0

var timer : Timer


func _init():
	type = Type.WAIT
	
	timer = Timer.new()
	timer.wait_time = wait_time
	sngl_Utility.get_scene_root().add_child(timer)


func reset(_overlay):
	set_wait_time(wait_time)


func execute():
	timer.start()


func set_wait_time(new_time : float) -> void:
	wait_time = new_time
	timer.wait_time = new_time
