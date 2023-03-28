class_name Trigger


enum Type { TIMED, TWITCH_CHAT, PROPERTY_SET }
var type : Type


signal triggered()


func duplicate() -> Trigger:
	return Trigger.new()


func match_properties(_overlay : Overlay) -> void:
	return


func trigger():
	emit_signal("triggered")
