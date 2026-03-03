extends Node

signal player_connected(peer_id: int)
signal player_disconnected(peer_id: int)
signal server_disconnected
signal connection_failed

const DEFAULT_PORT := 7777
const MAX_PLAYERS := 4

var peer: ENetMultiplayerPeer
var player_info := {}
var players_loaded := []


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func host_game(port: int = DEFAULT_PORT) -> Error:
	peer = ENetMultiplayerPeer.new()
	var error := peer.create_server(port, MAX_PLAYERS)

	if error != OK:
		return error

	multiplayer.multiplayer_peer = peer
	player_info[1] = PlayerData.get_player_info()

	return OK


func join_game(address: String, port: int = DEFAULT_PORT) -> Error:
	peer = ENetMultiplayerPeer.new()
	var error := peer.create_client(address, port)

	if error != OK:
		return error

	multiplayer.multiplayer_peer = peer
	return OK


func disconnect_game() -> void:
	if peer:
		peer.close()

	multiplayer.multiplayer_peer = null
	player_info.clear()
	players_loaded.clear()


func is_server() -> bool:
	return multiplayer.is_server()


func get_player_ids() -> Array:
	return player_info.keys()


@rpc("any_peer", "reliable")
func register_player(info: Dictionary) -> void:
	var sender_id := multiplayer.get_remote_sender_id()
	player_info[sender_id] = info
	player_connected.emit(sender_id)


@rpc("any_peer", "reliable")
func player_loaded() -> void:
	var sender_id := multiplayer.get_remote_sender_id()
	if sender_id not in players_loaded:
		players_loaded.append(sender_id)


func _on_peer_connected(id: int) -> void:
	register_player.rpc_id(id, PlayerData.get_player_info())


func _on_peer_disconnected(id: int) -> void:
	player_info.erase(id)
	players_loaded.erase(id)
	player_disconnected.emit(id)


func _on_connected_to_server() -> void:
	var my_info := PlayerData.get_player_info()
	register_player.rpc(my_info)
	player_info[multiplayer.get_unique_id()] = my_info


func _on_connection_failed() -> void:
	multiplayer.multiplayer_peer = null
	connection_failed.emit()


func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	player_info.clear()
	players_loaded.clear()
	server_disconnected.emit()
