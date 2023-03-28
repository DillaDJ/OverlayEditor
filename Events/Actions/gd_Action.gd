class_name Action


enum Type { PRINT, PROPERTY }
var type : Type


func duplicate() -> Action:
	return self


func match_properties(_overlay_from : Overlay) -> void:
	return


func execute():
	pass
