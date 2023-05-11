class_name Action
extends Resource


enum Type { NONE = -1, PRINT, PROPERTY, WAIT }
@export var type : Type = Type.NONE


func reset(_overlay : Overlay):
	pass


func match_properties(_overlay_from : Overlay) -> void:
	return


func execute():
	pass
