class_name BufferReader

var _buffer: PackedByteArray
var _offset: int

func _init(buffer: PackedByteArray):
	_buffer = buffer
	_offset = 0

func read() -> String:
	var length := read_u8()
	var res := _buffer.slice(_offset, _offset + length).get_string_from_utf8()
	_offset += res.length()
	return res
	
func read_u8() -> int:
	var res := _buffer.decode_u8(_offset)
	_offset += 1
	return res

func read_u32() -> int:
	var res := _buffer.decode_u32(_offset)
	_offset += 4
	return res

func read_float() -> float:
	var res := _buffer.decode_float(_offset)
	_offset += 4
	return res
	
func read_player() -> Dictionary:
	var id := read()
	var name := read()
	var color := read_u32()
	var x := read_float()
	var y := read_float()
	var dx := read_float()
	var dy := read_float()
	var score := read_u32()
	return {
		"id": id,
		"name": name,
		"color": Color(
			(color >> 24) / 255.0,
			((color >> 16) & 0xff) / 255.0,
			((color >> 8) & 0xff) / 255.0,
			(color & 0xff) / 255.0
		),
		"x": x,
		"y": y,
		"dx": dx,
		"dy": dy,
		"score": score,
	}

func read_player_update() -> Dictionary:
	var id := read()
	var x := read_float()
	var y := read_float()
	var dx := read_float()
	var dy := read_float()
	var score := read_u32()
	return {
		"id": id,
		"x": x,
		"y": y,
		"dx": dx,
		"dy": dy,
		"score": score,
	}
