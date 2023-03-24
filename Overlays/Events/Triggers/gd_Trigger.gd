class_name Trigger


enum Type { TIMED, TWITCH_CHAT, PROPERTY_SET }
var type : Type


signal triggered()


func trigger():
	emit_signal("triggered")
