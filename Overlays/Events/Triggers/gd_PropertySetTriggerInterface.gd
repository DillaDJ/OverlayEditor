extends VBoxContainer


@onready var checkbox : CheckBox = $CheckBox

@onready var vague_label 	: Label = $Description/VagueLabel
@onready var specific_label : Label = $Description/SpecificLabel
@onready var field_matcher 	: FieldMatcher = $Description/FieldMatcher


func _ready():
	checkbox.connect("toggled", Callable(self, "toggle_specific_value"))


func toggle_specific_value(pressed : bool) -> void:
	if pressed:
		vague_label.hide()
		specific_label.show()
		field_matcher.show()
	else:
		specific_label.hide()
		field_matcher.hide()
		vague_label.show()

