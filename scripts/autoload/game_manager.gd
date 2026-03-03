extends Node

signal area_unlocked(area_name: String)
signal game_state_changed(new_state: GameState)

enum GameState { MENU, PLAYING, PAUSED, DIALOGUE }

const MAX_PLAYERS := 4

var current_state: GameState = GameState.MENU
var unlocked_areas: Array[String] = ["city_center", "home"]
var current_map: String = "city_center"

# Area unlock requirements (mushrooms needed)
var area_requirements := {
	"park": 5,
	"market": 10,
	"forest": 20,
	"cave": 50
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func change_state(new_state: GameState) -> void:
	current_state = new_state
	game_state_changed.emit(new_state)

	match new_state:
		GameState.PAUSED:
			get_tree().paused = true
		_:
			get_tree().paused = false


func try_unlock_area(area_name: String) -> bool:
	if area_name in unlocked_areas:
		return true

	if area_name not in area_requirements:
		return false

	var required := area_requirements[area_name] as int
	if PlayerData.total_mushrooms_grown >= required:
		unlocked_areas.append(area_name)
		area_unlocked.emit(area_name)
		return true

	return false


func is_area_unlocked(area_name: String) -> bool:
	return area_name in unlocked_areas


func get_area_requirement(area_name: String) -> int:
	return area_requirements.get(area_name, 0)


func load_map(map_name: String) -> void:
	current_map = map_name
	var map_path := "res://scenes/maps/%s_map.tscn" % map_name
	get_tree().change_scene_to_file(map_path)


func start_game(is_multiplayer: bool = false) -> void:
	change_state(GameState.PLAYING)
	get_tree().change_scene_to_file("res://scenes/main/game_world.tscn")
