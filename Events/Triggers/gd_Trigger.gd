class_name Trigger
extends Resource


enum Type { TIMED, TWITCH_CHAT, PROPERTY }
@export var type : Type


signal triggered()


func duplicate_trigger() -> Trigger:
	return Trigger.new()


func match_properties(_overlay : Overlay) -> void:
	return


func trigger():
	emit_signal("triggered")
