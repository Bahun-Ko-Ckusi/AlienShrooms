extends Node

signal spores_changed(new_count: int)
signal mushrooms_changed(new_count: int)
signal inventory_changed

var player_name := "Player"
var player_color := Color.CYAN

# Inventory
var spores: Dictionary = {}  # spore_type: count
var mushrooms: Dictionary = {}  # mushroom_type: count
var total_spores_collected := 0
var total_mushrooms_grown := 0

# Spore types and their growth properties
var spore_data := {
	"common": {"grow_time": 30.0, "mushroom": "button"},
	"forest": {"grow_time": 45.0, "mushroom": "shiitake"},
	"rare": {"grow_time": 60.0, "mushroom": "truffle"},
	"glowing": {"grow_time": 90.0, "mushroom": "bioluminescent"}
}

# NPC request tracking
var completed_requests: Array[String] = []
var active_requests: Array[Dictionary] = []


func _ready() -> void:
	load_data()


func get_player_info() -> Dictionary:
	return {
		"name": player_name,
		"color": player_color
	}


func add_spore(spore_type: String, amount: int = 1) -> void:
	if spore_type not in spores:
		spores[spore_type] = 0

	spores[spore_type] += amount
	total_spores_collected += amount
	spores_changed.emit(get_total_spores())
	inventory_changed.emit()


func remove_spore(spore_type: String, amount: int = 1) -> bool:
	if spore_type not in spores or spores[spore_type] < amount:
		return false

	spores[spore_type] -= amount
	if spores[spore_type] <= 0:
		spores.erase(spore_type)

	spores_changed.emit(get_total_spores())
	inventory_changed.emit()
	return true


func add_mushroom(mushroom_type: String, amount: int = 1) -> void:
	if mushroom_type not in mushrooms:
		mushrooms[mushroom_type] = 0

	mushrooms[mushroom_type] += amount
	total_mushrooms_grown += amount
	mushrooms_changed.emit(get_total_mushrooms())
	inventory_changed.emit()


func remove_mushroom(mushroom_type: String, amount: int = 1) -> bool:
	if mushroom_type not in mushrooms or mushrooms[mushroom_type] < amount:
		return false

	mushrooms[mushroom_type] -= amount
	if mushrooms[mushroom_type] <= 0:
		mushrooms.erase(mushroom_type)

	mushrooms_changed.emit(get_total_mushrooms())
	inventory_changed.emit()
	return true


func get_total_spores() -> int:
	var total := 0
	for count in spores.values():
		total += count
	return total


func get_total_mushrooms() -> int:
	var total := 0
	for count in mushrooms.values():
		total += count
	return total


func has_spore(spore_type: String, amount: int = 1) -> bool:
	return spores.get(spore_type, 0) >= amount


func has_mushroom(mushroom_type: String, amount: int = 1) -> bool:
	return mushrooms.get(mushroom_type, 0) >= amount


func save_data() -> void:
	var save_dict := {
		"player_name": player_name,
		"player_color": player_color.to_html(),
		"spores": spores,
		"mushrooms": mushrooms,
		"total_spores_collected": total_spores_collected,
		"total_mushrooms_grown": total_mushrooms_grown,
		"completed_requests": completed_requests,
		"unlocked_areas": GameManager.unlocked_areas
	}

	var file := FileAccess.open("user://save_data.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_dict))


func load_data() -> void:
	if not FileAccess.file_exists("user://save_data.json"):
		return

	var file := FileAccess.open("user://save_data.json", FileAccess.READ)
	if not file:
		return

	var json := JSON.new()
	var parse_result := json.parse(file.get_as_text())
	if parse_result != OK:
		return

	var data: Dictionary = json.data
	player_name = data.get("player_name", "Player")
	player_color = Color.html(data.get("player_color", "#00FFFF"))
	spores = data.get("spores", {})
	mushrooms = data.get("mushrooms", {})
	total_spores_collected = data.get("total_spores_collected", 0)
	total_mushrooms_grown = data.get("total_mushrooms_grown", 0)
	completed_requests.assign(data.get("completed_requests", []))
