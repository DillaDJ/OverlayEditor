class_name PrintAction
extends Action


var property : Property


func _init():
	type = Type.PRINT


func execute():
	if property:
		print(property.get_property())


func change_property(new_property : Property) -> void:
	property = new_property
