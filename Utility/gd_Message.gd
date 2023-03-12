extends Panel

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var title 		: Label = $MessageLayout/Title
@onready var subtitle 	: Label = $MessageLayout/Subtitle


func show_message(title_msg, subtitle_msg):
	title.text = title_msg
	subtitle.text = subtitle_msg
	
	anim.play("fadeinout")
