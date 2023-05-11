class_name Trigger
extends Resource


enum Type { NONE = -1, TIMED, TWITCH_CHAT, PROPERTY }
@export var type : Type = Type.NONE

var enabled := false


signal triggered()


func reset(_overlay : Overlay):
	return


func match_properties(_overlay : Overlay) -> void:
	return


func trigger():
	if enabled:
		emit_signal("triggered")
