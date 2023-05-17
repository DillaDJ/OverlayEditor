extends Control


func _ready():
	$Close.connect("button_down", Callable(self, "hide"))
