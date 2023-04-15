class_name Action
extends Resource


enum Type { PRINT, PROPERTY, WAIT }
@export var type : Type


func reset(_overlay : Overlay):
	pass


func match_properties(_overlay_from : Overlay) -> void:
	return


func execute():
	pass
