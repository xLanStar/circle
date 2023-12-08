extends Node

const WaitTime: Array[int] = [5, 10, 15, 30, 60]

@export var timer: Timer
@export var label: Label
var tried: int = 0

func _ready() -> void:
	try_connect()
	Client.connected.connect(_try_connected)
	Client.disconnected.connect(_try_disconnected)

func try_connect() -> void:
	var wait_time: int = WaitTime[min(tried, len(WaitTime)-1)]
	label.text = "連線失敗，將於" + str(wait_time) + "秒後重新嘗試" if tried else "連線中..."
	timer.wait_time = wait_time
	timer.start()
	tried += 1
	Client.connect_to_url("ws://localhost:8080" if true else "ws://voidcloud.net:8080")

func _try_connected() -> void:
	timer.stop()
	Client.connected.disconnect(_try_connected)
	Client.disconnected.disconnect(_try_disconnected)
	get_tree().current_scene.queue_free()
	Game.enter()
	print("connect successful")

func _try_disconnected(_code: String, _reason: String) -> void:
	timer.stop()
	label.text = "無法連線至伺服器"
	Client.connected.disconnect(_try_connected)
	Client.disconnected.disconnect(_try_disconnected)
	print("connect failed")
