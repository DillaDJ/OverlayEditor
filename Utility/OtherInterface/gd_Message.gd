extends Panel

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var title 		: Label = $MessageLayout/Title
@onready var subtitle 	: Label = $MessageLayout/Subtitle


signal message_expired()


func finish_fade():
	message_expired.emit()
