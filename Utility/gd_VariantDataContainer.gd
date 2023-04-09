extends Resource
class_name VariantDataContainer


@export var current_data_type : Variant.Type

@export var bool_data 		: bool
@export var int_data 		: int
@export var float_data 		: float
@export var string_data 	: String
@export var vector2_data 	: Vector2
@export var vector4_data 	: Vector4
@export var color_data 		: Color
@export var texture_data 	: Vector4
@export var property_data 	: Property


func get_value() -> Variant:
	match current_data_type:
		TYPE_BOOL:
			return bool_data
		
		TYPE_INT:
			return int_data
		
		TYPE_FLOAT:
			return float_data
		
		TYPE_STRING:
			return string_data
		
		TYPE_STRING_NAME:
			return string_data
		
		TYPE_VECTOR2:
			return vector2_data
		
		TYPE_VECTOR4:
			return vector4_data
		
		TYPE_COLOR:
			return color_data
		
		TYPE_PROJECTION:
			return texture_data
		
		TYPE_OBJECT:
			return property_data.get_value()
	
	return null


func set_value(value : Variant) -> void:
	current_data_type = typeof(value) as Variant.Type
	
	match current_data_type:
		TYPE_BOOL:
			bool_data = value
		
		TYPE_INT:
			int_data = value
		
		TYPE_FLOAT:
			float_data = value
		
		TYPE_STRING:
			string_data = value
		
		TYPE_STRING_NAME:
			string_data = value
		
		TYPE_VECTOR2:
			vector2_data = value
		
		TYPE_VECTOR4:
			vector4_data = value
		
		TYPE_COLOR:
			color_data = value
		
		TYPE_PROJECTION:
			texture_data = value
		
		TYPE_OBJECT: # Property
			property_data.set_value(value)


func get_property() -> Property:
	if current_data_type == TYPE_OBJECT:
		return property_data
	return null


func set_property(prop : Property) -> void:
	current_data_type = TYPE_OBJECT
	property_data = prop

