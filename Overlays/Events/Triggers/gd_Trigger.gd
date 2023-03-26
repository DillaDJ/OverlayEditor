class_name Trigger


enum Type { TIMED, TWITCH_CHAT, PROPERTY_SET }
var type : Type


signal triggered()


func duplicate(_overlay : Overlay) -> Trigger:
	return Trigger.new()


func trigger():
	emit_signal("triggered")
