class_name PrintAction
extends Action


enum Modes { SET, ADD, SUBTRACT }


var property : Property
var value_to_change_by


func _init():
	type = Type.PROPERTY


func execute():
	pass


func change_property(new_property : Property) -> void:
	property = new_property
