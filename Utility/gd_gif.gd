# Static class to help process gifs into AnimatedTextures
class_name gif


static func is_valid(data : PackedByteArray) -> bool:
	# GIF file header
	var header : PackedByteArray = [data.decode_u8(0), data.decode_u8(1), data.decode_u8(2)]
	var version: PackedByteArray = [data.decode_u8(3), data.decode_u8(4), data.decode_u8(5)]
	if header.get_string_from_ascii() != "GIF" or version.get_string_from_ascii() != "89a":
		printerr("GIF FILE INVALID")
		return false
	return true


static func get_dimensions(data : PackedByteArray) -> Vector2i:
	var width 	: int = data.decode_u16(6)
	var height 	: int = data.decode_u16(8)
	return Vector2i(width, height)


static func get_color_table(data : PackedByteArray) -> Array:
	# Logical screen descriptor packed field and flags
	var packed_fields 		: int 	= data.decode_u8(10)
	var global_color_table 	: bool 	= packed_fields & 0b10000000
	var global_table_size 	: int 	= packed_fields & 0b00000111
	
	# Global color table
	var global_colors : Array[Color] = []
	if global_color_table:
		global_table_size = int(pow(2, global_table_size + 1))
	
		for i in range(global_table_size):
			var color := Color8(data.decode_u8(13 + i * 3), data.decode_u8(14 + i * 3), data.decode_u8(15 + i * 3))
			global_colors.append(color)
	return global_colors


# Frame processing
static func split_into_frames(data : PackedByteArray) -> Array:
	var global_colors : Array = get_color_table(data)
	var decompressed_frame_data : Array = []
	var next_transparent_idx 	: int = -1
	var next_delay_time 		: int = -1
	
	# 13 = Header bytes + 1 (the new current byte)
	var byte_idx : int= 13 + 3 * global_colors.size()
	while true:
		var block_type = data.decode_u8(byte_idx)
		
		match block_type:
			0x21: # Extension
				var extension_label = data.decode_u8(byte_idx + 1)
				byte_idx += 2
				
				if extension_label == 0x01 or extension_label == 0xFF: 	# Plain Text Extension or application extention
						var block_size = data.decode_u8(byte_idx) + 1 	# Skips data blocks
						while true:
							byte_idx += block_size
							block_size = data.decode_u8(byte_idx)
							if block_size == 0:
								if data.decode_u8(byte_idx + 1) != 0: # Block terminator
									printerr("No block terminator")
								byte_idx += 2
								break
						
				elif extension_label == 0xF9: # Graphic Control Extension
						var block_size 		: int = data.decode_u8(byte_idx)
						var has_transparent : bool = data.decode_u8(byte_idx + 1) & 0b00000001
						next_delay_time = data.decode_u16(byte_idx + 2)
						next_transparent_idx = data.decode_u8(byte_idx + 4) if has_transparent else -1
						byte_idx += block_size
						if data.decode_u8(byte_idx + 1) != 0:
							printerr("No block terminator")
						byte_idx += 2 # Skip past terminator
						
				elif extension_label == 0xFE: # Comment Extension
						printerr("Commend extension not supported")
			
			0x2C: # Image Data
				# Image descriptor field flags
				var frame_packed_fields := data.decode_u8(byte_idx + 9)
				var local_color_table 	: bool = frame_packed_fields & 0b10000000
				var local_table_size 	: int  = frame_packed_fields & 0b00000111
				byte_idx += 10
				
				# Local color table
				var local_colors : Array[Color] = []
				if local_color_table:
					local_table_size = int(pow(2, local_table_size + 1))
					
					for i in range(local_table_size):
						var color := Color8(data.decode_u8(byte_idx + i * 3), data.decode_u8(byte_idx + 1 + i * 3), data.decode_u8(byte_idx + 2 + i * 3))
						local_colors.append(color)
				byte_idx += 3 * (local_table_size)
				
				# Image data block
				var min_code_size 	: int = data.decode_u8(byte_idx)
				var block_size		: int = data.decode_u8(byte_idx + 1)
				var image_data		: PackedByteArray = []
				byte_idx += 2
				
				while true:
					if block_size == 0:
						block_size = data.decode_u8(byte_idx)
						byte_idx += 1
						if block_size == 0:
							break
					image_data.append(data.decode_u8(byte_idx))
					block_size -= 1
					byte_idx += 1
				
				var frame_data = decompress_frame(image_data, local_colors if local_color_table else global_colors, min_code_size)
				frame_data.append(next_delay_time)
				frame_data.append(next_transparent_idx)
				decompressed_frame_data.append(frame_data)
			
			0x3B: # EOF
				return decompressed_frame_data
			
			0: # EOF Skipped
				printerr("Error in parsing, EoF skipped")
				break
	return []


static func decompress_frame(image_data : PackedByteArray, color_table : Array, min_code_size : int) -> PackedByteArray:
	var index_data : PackedByteArray = []
	var base_code_table : Dictionary = {}
	
	# Init base color table
	var base_code_table_size := int(pow(2, min_code_size))
	for i in range(color_table.size()):
		base_code_table[i] = [i]
	base_code_table[base_code_table_size + 0] = "Clear"
	base_code_table[base_code_table_size + 1] = "EOI"
	
	# Init our color table
	var code_table : Dictionary = base_code_table.duplicate(true)
	var next_available_code := color_table.size()
	while base_code_table.has(next_available_code):
		next_available_code += 1
	
	# Decompress
	var current_code_size = min_code_size + 1
	var current_code  	:= 0
	var previous_code 	:= 0
	var current_bit_idx := 0 # From the back
	
	previous_code = get_next_n_bits(image_data, current_bit_idx, current_code_size)
	current_bit_idx += current_code_size
	
	if typeof(code_table[previous_code]) == TYPE_STRING: # Skip clear code
		previous_code = get_next_n_bits(image_data, current_bit_idx, current_code_size)
		current_bit_idx += current_code_size
	for pixel_idx in code_table[previous_code]:
		index_data.append(pixel_idx)
	
	while current_bit_idx <= 8 * image_data.size():
		current_code = get_next_n_bits(image_data, current_bit_idx, current_code_size)
		
		if code_table.has(current_code):
			if typeof(code_table[current_code]) == TYPE_STRING:
				if code_table[current_code] == "Clear":
					current_bit_idx += current_code_size
					
					code_table = base_code_table.duplicate(true)
					current_code_size = min_code_size + 1
					next_available_code = color_table.size()
					while base_code_table.has(next_available_code):
						next_available_code += 1
					
					previous_code = get_next_n_bits(image_data, current_bit_idx, current_code_size)
					current_bit_idx += current_code_size
					
					continue
				elif code_table[current_code] == "EOI":
					break
			
			for pixel_idx in code_table[current_code]:
				index_data.append(pixel_idx)
			
			code_table[next_available_code] = code_table[previous_code].duplicate(true)
			code_table[next_available_code].append(code_table[current_code][0])
		else:
			var new_code = code_table[previous_code].duplicate(true)
			new_code.append(code_table[previous_code][0])
			for pixel_idx in new_code:
				index_data.append(pixel_idx)
			
			code_table[current_code] = new_code
		
		current_bit_idx += current_code_size
		if next_available_code + 1 >> current_code_size > 0:
			current_code_size += 1
		previous_code = current_code
		next_available_code += 1
	
	return index_data


static func get_frame_as_image(decompressed_data : PackedByteArray, dimensions : Vector2i, colors : Array) -> Image:
	var image 			:= Image.new()
	var color_data 		: PackedByteArray = []
	var transparency_idx:= decompressed_data[-1]
	decompressed_data.remove_at(decompressed_data.size() -1)
	decompressed_data.remove_at(decompressed_data.size() -1)
	
	var i := 0
	for y in range(dimensions.y):
		for x in range(dimensions.x):
			if i > decompressed_data.size() -1 or decompressed_data[i] == transparency_idx:
				color_data.append(0)
				color_data.append(0)
				color_data.append(0)
				color_data.append(0)
				i += 1;
				continue
			
			var color : Color = colors[decompressed_data[i]]
			color_data.append(color.r8)
			color_data.append(color.g8)
			color_data.append(color.b8)
			color_data.append(color.a8)
			i += 1
	
	image.set_data(dimensions.x, dimensions.y, false, Image.FORMAT_RGBA8, color_data)
	return image


static func get_anim_from_frame_data(decompressed_frames : Array, dimensions : Vector2i, colors : Array) -> AnimatedTexture:
	var animated_texture := AnimatedTexture.new()
	animated_texture.frames = decompressed_frames.size()
	
	for i in range(decompressed_frames.size()):
		var anim_delay 		: int = decompressed_frames[i][-2]
		var frame_image		:= get_frame_as_image(decompressed_frames[i], dimensions, colors)
		var frame_texture 	:= ImageTexture.create_from_image(frame_image)
		
		animated_texture.set_frame_texture(i, frame_texture)
		animated_texture.set_frame_duration(i, anim_delay * 0.01)
	
	return animated_texture


# Utility
# Bits are packed backwards in gifs, apparently
static func get_next_n_bits(data : PackedByteArray, from : int, length : int) -> int:
	var bit  	: int = 1 << (from % 8) # Bit mask
	var byte 	: int = int(floor(from / 8.0))
	var result 	:= 0
	
	for i in range(length):
		if bit > 0b10000000:
			byte += 1
			if byte > data.size() - 1:
				return result
			bit = 1
		
		if data[byte] & bit:
			result += 0b1 << i
		bit <<= 1
		
	return result


static func print_block(data : PackedByteArray, from : int, to : int) -> void:
	for i in range(from, to):
		print("%d: %d" % [i, data.decode_u8(i)])
