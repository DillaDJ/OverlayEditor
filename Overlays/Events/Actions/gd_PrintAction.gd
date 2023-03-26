class_name PrintAction
extends Action


var property : Property


func _init():
	type = Type.PRINT


func duplicate(overlay : Overlay) -> Action:
	var duplicated_action = PrintAction.new()
	
	if property:
		var matching_property = property.find_equivalent_property(overlay)
		duplicated_action.change_property(matching_property)
	
	return duplicated_action


func execute():
	if property:
		print(property.get_property())


func change_property(new_property : Property) -> void:
	property = new_property
