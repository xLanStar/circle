extends Node

signal connected
signal disconnected(code: int, reason: String)

enum Type {
	Init = 0,
	Join = 1,
	Leave = 2,
	AddPlayer = 3,
	RemovePlayer = 4,
	Update = 5,
	Move = 6,
}

var _socket: WebSocketPeer
var _state: WebSocketPeer.State = WebSocketPeer.STATE_CLOSED
var hooks = {}
var id: String
var tick_ready: bool

func _ready() -> void:
	set_physics_process(false)
	hook(Type.Init, _init_connection)

func _physics_process(_delta: float) -> void:
	tick_ready = !tick_ready
	_socket.poll()
	var state = _socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while _socket.get_available_packet_count():
			var buffer := BufferReader.new(_socket.get_packet())
			var type := buffer.read_u8() as Type
			if type in hooks:
				for cb in hooks[type]:
					cb.call(buffer)
	if _state != state:
		print("[Client] state changed: ", state)
		_state = state
		if state == WebSocketPeer.STATE_OPEN:
			connected.emit()
		elif state == WebSocketPeer.STATE_CLOSED:
			var code := _socket.get_close_code()
			var reason := _socket.get_close_reason()
			disconnected.emit(code, reason)
			print("[Client] closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
			set_physics_process(false) # Stop processing.

func hook(type: Type, callable: Callable) -> void:
	if type in hooks:
		hooks[type].append(callable)
	else:
		hooks[type] = [callable]

func unhook(type: String, callable: Callable) -> void:
	if type in hooks:
		hooks[type].erase(callable)

func connect_to_url(url: String) -> void:
	print("[Client] connect to url: ", url)
	if _socket != null:
		_socket.close()
	_socket = WebSocketPeer.new()
	_socket.inbound_buffer_size = 1000000
	_socket.connect_to_url(url)
	set_physics_process(true)

func send(data: PackedByteArray) -> void:
	#print("[Client] send: ", data)
	_socket.send(data)

func _init_connection(buffer: BufferReader) -> void:
	id = buffer.read()
