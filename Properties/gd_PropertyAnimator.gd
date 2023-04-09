class_name PropertyAnimator


var property : Property

var from 	: VariantDataContainer
var to 		: VariantDataContainer

var anim_length := 0.0
var anim_time := 0.0

var animating := false


signal animation_finished()


func _init() -> void:
	from 	= VariantDataContainer.new()
	to 		= VariantDataContainer.new()



func start(to_value : Variant) -> void:
	from.set_value(property.get_value())
	to.set_value(to_value)
	
	if typeof(from.get_value()) != typeof(to.get_value()):
		printerr("CANNOT ANIMATE DIFFERENT TYPES")
		return
	
	anim_time = 0
	animating = true


func animate(delta : float) -> void:
	if animating:
		var new_value = lerp(from.get_value(), to.get_value(), anim_time / anim_length)
		property.set_value(new_value)
		
		anim_time += delta
		if anim_time >= anim_length:
			anim_time = anim_length
			animating = false
			
			animation_finished.emit()


func set_property(prop : Property):
	property = prop


func set_anim_time(value : float):
	anim_length = value


func set_anim_length(value : float):
	anim_length = value


func set_anim_type(type : int):
	print(type)
