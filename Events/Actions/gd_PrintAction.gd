class_name PrintAction
extends Action


@export var property : Property


func _init():
	type = Type.PRINT


func match_properties(overlay : Overlay) -> void:
	var prop = property.find_equivalent_property(overlay)
	set_property(prop)


func execute():
	if property:
		print(property.get_value())


func set_property(new_property : Property) -> void:
	property = new_property
