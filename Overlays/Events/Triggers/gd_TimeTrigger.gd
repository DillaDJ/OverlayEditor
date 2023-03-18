class_name TimeTrigger
extends Trigger


var timer : Timer
var trigger_time : float = 3.0


func _init():
	type = Type.TIMED
	
	timer = Timer.new()
	timer.wait_time = trigger_time
	timer.connect("timeout", Callable(self, "trigger"))
	
	sngl_Utility.get_scene_root().add_child(timer)
	sngl_Utility.sync_timer.connect("timeout", Callable(timer, "start"))
	sngl_Utility.sync_timer.start()


func edit_time(new_time : float):
	trigger_time = new_time
	timer.wait_time = new_time
	sngl_Utility.sync_timer.start()
