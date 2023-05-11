class_name PropertyAnimator
extends Resource


enum  Type { LINEAR, SIN_IN, SIN_OUT, SIN_INOUT, CUBIC_IN, CUBIC_OUT, CUBIC_INOUT, CIRC_IN, CIRC_OUT, CIRC_INOUT, 
			ELASTIC_IN, ELASTIC_OUT, ELASTIC_INOUT, BACK_IN, BACK_OUT, BACK_INOUT, BOUNCE_IN, BOUNCE_OUT, BOUNCE_INOUT }

# Easing constants
const c1 = 1.70158;
const c2 = c1 * 1.525;
const c3 = c1 + 1;
const c4 = (2 * PI) / 3;
const c5 = (2 * PI) / 4.5;
const n1 = 7.5625;
const d1 = 2.75;

var from 	: VariantDataContainer = null
var to 		: VariantDataContainer = null

var type 	: Type = Type.LINEAR
var length 	:= 0.0
var time 	:= 0.0

var property : Property
var animating := false


signal animation_finished()


func start(to_value : Variant, new_length : float, new_type : Type) -> void:
	length = new_length
	type = new_type
	from.set_value(property.get_value())
	to.set_value(to_value)
	
	if from.current_data_type != to.current_data_type:
		printerr("CANNOT ANIMATE DIFFERENT TYPES")
		return
		
	time = 0
	animating = true


func stop() -> void:
	from.set_value(property.get_value())
	to.set_value(property.get_value())
	
	time = 0
	animating = false


func animate(delta : float) -> void:
	if animating:
		var e_time = ease_time(time / length)
		var new_value = lerp(from.get_value(), to.get_value(), e_time)

		if new_value != from.get_value():
			property.set_value(new_value)

		time += delta

		if time >= length:
			time = length
			property.set_value(to.get_value())
			animating = false

			animation_finished.emit()

 
func ease_time(e_time : float) -> float:
	match type:
		Type.SIN_IN:
			return 1 - cos((e_time * PI) / 2);
		Type.SIN_OUT:
			return sin((e_time * PI) / 2);
		Type.SIN_INOUT:
			return -(cos(PI * e_time) - 1) / 2;
		Type.CUBIC_IN:
			return e_time * e_time * e_time;
		Type.CUBIC_OUT:
			return 1 - pow(1 - e_time, 3);
		Type.CUBIC_INOUT:
			return 4 * e_time * e_time * e_time if e_time < 0.5 else 1 - pow(-2 * e_time + 2, 3) / 2;
		Type.CIRC_IN:
			return 1 - sqrt(1 - pow(e_time, 2));
		Type.CIRC_OUT:
			return sqrt(1 - pow(e_time - 1, 2));
		Type.CIRC_INOUT:
			return (1 - sqrt(1 - pow(2 * e_time, 2))) / 2 if e_time < 0.5 else (sqrt(1 - pow(-2 * e_time + 2, 2)) + 1) / 2;
		Type.ELASTIC_IN:
			if e_time == 0: 
				return 0 
			elif e_time == 1: 
				return 1
			else: 
				return -pow(2, 10 * e_time - 10) * sin((e_time * 10 - 10.75) * c4)
		Type.ELASTIC_OUT:
			if e_time == 0: 
				return 0 
			elif e_time == 1: 
				return 1
			else: 
				return pow(2, -10 * e_time) * sin((e_time * 10 - 0.75) * c4) + 1
		Type.ELASTIC_INOUT:
			if e_time == 0: 
				return 0 
			elif e_time == 1: 
				return 1
			else:
				if e_time < 0.5:
					return -(pow(2, 20 * e_time - 10) * sin((20 * e_time - 11.125) * c5)) / 2  
				else:
					return (pow(2, -20 * e_time + 10) * sin((20 * e_time - 11.125) * c5)) / 2 + 1
		Type.BACK_IN:
			return c3 * e_time * e_time * e_time - c1 * e_time * e_time;
		Type.BACK_OUT:
			return 1 + c3 * pow(e_time - 1, 3) + c1 * pow(e_time - 1, 2);
		Type.BACK_INOUT:
			return (pow(2 * e_time, 2) * ((c2 + 1) * 2 * e_time - c2)) / 2 if e_time < 0.5 else (pow(2 * e_time - 2, 2) * ((c2 + 1) * (e_time * 2 - 2) + c2) + 2) / 2;
		Type.BOUNCE_IN:
			return 1 - ease_out_bounce(1 - e_time)
		Type.BOUNCE_OUT:
			return ease_out_bounce(e_time)
		Type.BOUNCE_INOUT:
			return (1 - ease_out_bounce(1 - 2 * e_time)) / 2 if e_time < 0.5 else (1 + ease_out_bounce(2 * e_time - 1)) / 2
	return e_time


func ease_out_bounce(e_time : float):
	if e_time < 1 / d1:
		return n1 * e_time * e_time
	elif e_time < 2 / d1:
		e_time -= 1.5 / d1
		return n1 * e_time * e_time + 0.75
	elif e_time < 2.5 / d1:
		e_time -= 2.25 / d1
		return n1 * e_time * e_time + 0.9375
	else:
		e_time -= 2.625 / d1
		return n1 * e_time * e_time + 0.984375


func set_property(prop : Property):
	property = prop
