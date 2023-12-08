class_name BufferWriter

var buffer: PackedByteArray
var _offset: int

func _init(size: int):
	buffer = PackedByteArray()
	buffer.resize(size)
	_offset = 0

func write(value: String) -> void:
	write_u8(value.length())
	var str_buffer := value.to_utf8_buffer()
	for i in str_buffer.size():
		buffer[_offset + i] = str_buffer[i]
	_offset += str_buffer.size()
	
func write_u8(value: int) -> void:
	buffer.encode_u8(_offset, value)
	_offset += 1

func write_u32(value: int) -> void:
	buffer.encode_u32(_offset, value)
	_offset += 4

func write_float(value: float) -> void:
	buffer.encode_float(_offset, value)
	_offset += 4
	
func write_player(player_data: Dictionary) -> void:
	write(player_data.id)
	write(player_data.name)
	write_u32(player_data.color)
	write_float(player_data.x)
	write_float(player_data.y)
	write_float(player_data.dx)
	write_float(player_data.dy)
	write_u32(player_data.score)
	
