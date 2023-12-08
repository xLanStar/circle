extends Node

const PlayerScene: PackedScene = preload("res://player/player.tscn")

@export var background: ColorRect
@export var menu: Menu
@export var camera: Camera2D
@export var dot_meshes: MultiMeshInstance2D
var players: Dictionary = {}
var dots_idx: Dictionary = {}

func _ready() -> void:
	menu.hide()
	background.hide()
	Client.hook(Client.Type.Init, _init_game)
	Client.hook(Client.Type.AddPlayer, _add_player)
	Client.hook(Client.Type.RemovePlayer, _remove_player)
	Client.hook(Client.Type.Update, _update)

func _init_game(buffer: BufferReader) -> void:
	Player.MapSize = buffer.read_u32()
	Player.MovementSpeed = buffer.read_u32()
	# add players
	var player_count := buffer.read_u32()
	for i in player_count:
		_add_player(buffer)
	# add dots
	dot_meshes.multimesh.instance_count = buffer.read_u32()
	for j in dot_meshes.multimesh.instance_count:
		var id := buffer.read_u32()
		dots_idx[id] = j
		dot_meshes.multimesh.set_instance_transform_2d(j, Transform2D(0, Vector2(id >> 16, id & 0xffff)))

func _add_player(buffer: BufferReader) -> void:
	var player_data := buffer.read_player()
	print("_add_player: ", player_data)
	var player_object := PlayerScene.instantiate()
	player_object.set_data(player_data)
	add_child(player_object)
	player_object.add_to_group("player")
	players[player_object.id] = player_object
	
func _remove_player(buffer: BufferReader) -> void:
	var player_id := buffer.read()
	print("_remove_player: ", player_id)
	if player_id not in players:
		prints(player_id, "not in", players)
		return
	var player_object = players[player_id]
	player_object.queue_free()
	players.erase(player_id)
	if player_id == Client.id:
		game_over()

func _update(buffer: BufferReader) -> void:
	var state := buffer.read_u8()
	var player_count := buffer.read_u32()
	for i in player_count:
		var player_update := buffer.read_player_update()
		players[player_update.id].update(player_update)
	if state & 0x1:
		var dot_count := buffer.read_u32()
		for i in dot_count:
			var old_dot_id := buffer.read_u32()
			var new_dot_id := buffer.read_u32()
			var idx: int = dots_idx[old_dot_id]
			dots_idx.erase(old_dot_id)
			dots_idx[new_dot_id] = idx
			dot_meshes.multimesh.set_instance_transform_2d(idx, Transform2D(0, Vector2(new_dot_id >> 16, new_dot_id & 0xffff)))
			
func enter() -> void:
	menu.show()
	background.show()
	Client.disconnected.connect(_on_client_disconnected)

func _on_client_disconnected(_code: int, _reason: String) -> void:
	Client.disconnected.disconnect(_on_client_disconnected)
	menu.hide()
	background.hide()
	dot_meshes.multimesh.instance_count = 0
	for child in get_children():
		if child.is_in_group("player"):
			child.queue_free()
	get_tree().change_scene_to_file("res://main.tscn")

func _on_menu_submit(input_name: String, color: Color):
	var buffer := BufferWriter.new(2 + input_name.length() + 4)
	buffer.write_u8(Client.Type.Join)
	buffer.write(input_name)
	buffer.write_u32(color.to_rgba32())
	start()
	Client.send(buffer.buffer)

func start() -> void:
	menu.hide()

func game_over() -> void:
	menu.show()
