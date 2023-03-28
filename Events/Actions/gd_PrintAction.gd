class_name PrintAction
extends Action


var property : Property


func _init():
	type = Type.PRINT


func duplicate() -> Action:
	var duplicated_action = PrintAction.new()
	
	duplicated_action.property = property
	
	return duplicated_action


func match_properties(overlay : Overlay) -> void:
	var prop = property.find_equivalent_property(overlay)
	change_property(prop)


func execute():
	if property:
		print(property.get_property())


func change_property(new_property : Property) -> void:
	property = new_property