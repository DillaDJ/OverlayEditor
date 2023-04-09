extends VBoxContainer


@onready var caret_button 	: Button = $HeaderBG/HeaderLayout/Caret
@onready var list_container : Control = $PropertyBG
@onready var list : ItemList = $PropertyBG/PropertyList/GlobalPropertyList

var global_properties : Array[Property]

signal property_selected(property : Property)


func _ready():
	Property.create_read(global_properties, "Screen Dimensions", TYPE_VECTOR2, Callable(sngl_Utility, "get_screen_size"), true)
	
	for property in global_properties:
		list.add_item(property.prop_name)
	
	caret_button.connect("toggled", Callable(self, "toggle_item_visibility"))
	list.connect("item_selected", Callable(self, "select_global_property"))


func toggle_item_visibility(showing : bool):
	if showing:
		caret_button.icon = sngl_Utility.caret_on
		list_container.show()
	else:
		caret_button.icon = sngl_Utility.caret_off
		list_container.hide()


func match_property_types(type_to_match : Variant.Type):
	if type_to_match == TYPE_NIL:
		set_properties_disabled(false)
		return
	
	for i in range(global_properties.size()):
		if (global_properties[i].type == TYPE_STRING or global_properties[i].type == TYPE_STRING_NAME) and \
		(type_to_match == TYPE_STRING or type_to_match == TYPE_STRING_NAME):
			list.set_item_disabled(i, false)
			return

		if global_properties[i].type == type_to_match:
			list.set_item_disabled(i, false)
		else:
			list.set_item_disabled(i, true)


func set_properties_disabled(value : bool):
	for i in range(list.item_count):
		list.set_item_disabled(i, value)


func select_global_property(idx : int):
	property_selected.emit(global_properties[idx])


func deselect_all():
	list.deselect_all()
