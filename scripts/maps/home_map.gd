extends Node2D

const GrowingStationScene := preload("res://scenes/objects/growing_station.tscn")

@onready var growing_stations_container: Node2D = $GrowingStations
@onready var exit_door: Area2D = $ExitDoor

var growing_stations: Array[GrowingStation] = []


func _ready() -> void:
	setup_growing_stations()
	setup_exit_door()


func setup_growing_stations() -> void:
	var station_positions := [
		Vector2(-100, -50),
		Vector2(0, -50),
		Vector2(100, -50)
	]

	for i in station_positions.size():
		var station := GrowingStationScene.instantiate() as GrowingStation
		station.station_id = i
		station.global_position = station_positions[i]
		growing_stations_container.add_child(station)
		growing_stations.append(station)

		station.mushroom_ready.connect(_on_mushroom_ready.bind(i))


func setup_exit_door() -> void:
	exit_door.add_to_group("interactable")


func _on_mushroom_ready(mushroom_type: String, station_id: int) -> void:
	print("Mushroom ready at station %d: %s" % [station_id, mushroom_type])


func get_station_status() -> Array:
	var status := []
	for station in growing_stations:
		status.append({
			"id": station.station_id,
			"state": station.current_state,
			"spore": station.planted_spore_type,
			"mushroom": station.resulting_mushroom
		})
	return status
