extends Node2D

const PlayerScene := preload("res://scenes/player/player.tscn")
const CityMapScene := preload("res://scenes/maps/city_map.tscn")
const HomeMapScene := preload("res://scenes/maps/home_map.tscn")

@onready var current_map_container: Node2D = $CurrentMap
@onready var players_container: Node2D = $Players
@onready var camera: Camera2D = $Camera2D

var current_map: Node2D
var local_player: Player


func _ready() -> void:
	load_map("city")
	spawn_local_player()

	if multiplayer.has_multiplayer_peer():
		MultiplayerManager.player_connected.connect(_on_player_connected)
		MultiplayerManager.player_disconnected.connect(_on_player_disconnected)


func load_map(map_name: String) -> void:
	# Clear current map
	for child in current_map_container.get_children():
		child.queue_free()

	# Load new map
	var map_scene: PackedScene
	match map_name:
		"city":
			map_scene = CityMapScene
		"home":
			map_scene = HomeMapScene
		_:
			map_scene = CityMapScene

	current_map = map_scene.instantiate()
	current_map_container.add_child(current_map)

	# Connect area triggers
	connect_area_triggers()


func connect_area_triggers() -> void:
	var triggers := current_map.get_node_or_null("AreaTriggers")
	if not triggers:
		return

	for trigger in triggers.get_children():
		if trigger is Area2D:
			trigger.body_entered.connect(_on_area_trigger_entered.bind(trigger.name))


func spawn_local_player() -> void:
	var player_id := 1
	if multiplayer.has_multiplayer_peer():
		player_id = multiplayer.get_unique_id()

	local_player = spawn_player(player_id)


func spawn_player(peer_id: int) -> Player:
	var player := PlayerScene.instantiate() as Player
	player.name = str(peer_id)
	player.player_id = peer_id

	# Get spawn point
	var spawn_point := get_spawn_point()
	player.global_position = spawn_point

	players_container.add_child(player)
	return player


func get_spawn_point() -> Vector2:
	var spawn_marker := current_map.get_node_or_null("PlayerSpawnPoint")
	if spawn_marker:
		return spawn_marker.global_position
	return Vector2.ZERO


func _on_area_trigger_entered(body: Node2D, trigger_name: String) -> void:
	if body is not Player:
		return

	if body != local_player:
		return

	match trigger_name:
		"HomeEntrance":
			transition_to_map("home")
		"ExitDoor":
			transition_to_map("city")


func transition_to_map(map_name: String) -> void:
	load_map(map_name)

	# Reposition player
	local_player.global_position = get_spawn_point()


func _on_player_connected(peer_id: int) -> void:
	spawn_player(peer_id)


func _on_player_disconnected(peer_id: int) -> void:
	var player := players_container.get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
