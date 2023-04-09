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


func reset() -> void:
	reset_timer()


func duplicate_trigger() -> Trigger:
	var duplicated_trigger = TimeTrigger.new()
	duplicated_trigger.edit_time(trigger_time)
	return duplicated_trigger


func edit_time(new_time : float):
	trigger_time = new_time
	reset_timer()


func reset_timer() -> void:
	timer.wait_time = trigger_time
	sngl_Utility.sync_timer.start()


func get_time() -> float:
	return timer.time_left
