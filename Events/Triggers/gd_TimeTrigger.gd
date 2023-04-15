class_name TimeTrigger
extends Trigger


var timer : Timer
@export var trigger_time : float = 3.0


func _init():
	type = Type.TIMED
	
	timer = Timer.new()
	timer.connect("timeout", Callable(self, "trigger"))
	
	sngl_Utility.get_scene_root().add_child(timer)
	sngl_Utility.sync_timer.connect("timeout", Callable(timer, "start"))
	
	reset_timer()


func reset(_overlay : Overlay) -> void:
	reset_timer()


func edit_time(new_time : float):
	trigger_time = new_time
	reset_timer()


func reset_timer() -> void:
	timer.wait_time = trigger_time
	sngl_Utility.sync_timer.start()


func get_time() -> float:
	return timer.time_left
