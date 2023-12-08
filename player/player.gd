class_name Player
extends Sprite2D

static var MapSize = 16384
static var MovementSpeed: int = 100

@export var label: Label

var id: String = ""
var size: float = 1.0
var score: int = -1
var velocity: Vector2

func set_data(player_data: Dictionary) -> void:
	print(id, name, " set data ", player_data)
	#print("set_data", player_data)
	id = player_data.id
	name = player_data.name
	label.text = name
	material.set_shader_parameter("color", player_data.color)
	update(player_data)

func update(player_data: Dictionary) -> void:
	position = Vector2(player_data.x, player_data.y)
	velocity = Vector2(player_data.dx, player_data.dy)
	if score != player_data.score:
		score = player_data.score
		size = 1.0 + (player_data.score / 20.0)
		#print("update player: ", player_data, " size: ",  size)
		# avoid scale setter influence performance
		scale = Vector2(size, size)

func _physics_process(delta: float) -> void:
	if id == Client.id:
		# authoritied
		velocity = position.direction_to(get_global_mouse_position())
		if Client.tick_ready:
			# send normalized direction
			var buffer := BufferWriter.new(9)
			buffer.write_u8(Client.Type.Move)
			buffer.write_float(velocity.x)
			buffer.write_float(velocity.y)
			Client.send(buffer.buffer)
	# multiply speed
	position = position.lerp(position + velocity * MovementSpeed, delta).clamp(Vector2.ZERO, Vector2(MapSize, MapSize))
	if id == Client.id:
		Game.camera.position = position
		var target_zoom := Vector2(3 / size, 3 / size)
		if not Game.camera.zoom.is_equal_approx(target_zoom):
			Game.camera.zoom = Game.camera.zoom.lerp(target_zoom, 0.2)
