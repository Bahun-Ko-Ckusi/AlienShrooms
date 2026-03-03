extends Area2D
class_name GrowingStation

signal mushroom_ready(mushroom_type: String)

enum StationState { EMPTY, GROWING, READY }

@export var station_id := 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var growth_timer: Timer = $GrowthTimer
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var station_label: Label = $StationLabel

var current_state: StationState = StationState.EMPTY
var planted_spore_type: String = ""
var resulting_mushroom: String = ""
var player_nearby: Player = null


func _ready() -> void:
	add_to_group("growing_stations")
	add_to_group("interactable")
	update_display()


func _process(_delta: float) -> void:
	if current_state == StationState.GROWING:
		var progress := 1.0 - (growth_timer.time_left / growth_timer.wait_time)
		progress_bar.value = progress * 100


func interact(player: Player) -> void:
	match current_state:
		StationState.EMPTY:
			show_plant_options(player)
		StationState.GROWING:
			# Show progress info
			var time_left := int(growth_timer.time_left)
			station_label.text = "%ds left" % time_left
		StationState.READY:
			harvest(player)


func show_plant_options(player: Player) -> void:
	# Check available spores
	var available_spores := []
	for spore_type in PlayerData.spores:
		if PlayerData.spores[spore_type] > 0:
			available_spores.append(spore_type)

	if available_spores.is_empty():
		station_label.text = "No spores!"
		return

	# For now, plant the first available spore
	# TODO: Show selection UI
	plant_spore(available_spores[0])


func plant_spore(spore_type: String) -> void:
	if not PlayerData.remove_spore(spore_type):
		return

	planted_spore_type = spore_type
	var spore_info: Dictionary = PlayerData.spore_data.get(spore_type, {})
	resulting_mushroom = spore_info.get("mushroom", "button")
	var grow_time: float = spore_info.get("grow_time", 30.0)

	growth_timer.wait_time = grow_time
	growth_timer.start()

	current_state = StationState.GROWING
	update_display()


func harvest(player: Player) -> void:
	PlayerData.add_mushroom(resulting_mushroom)

	planted_spore_type = ""
	resulting_mushroom = ""
	current_state = StationState.EMPTY
	update_display()


func update_display() -> void:
	match current_state:
		StationState.EMPTY:
			station_label.text = "Empty"
			progress_bar.visible = false
			sprite.modulate = Color(0.5, 0.4, 0.3)
		StationState.GROWING:
			station_label.text = "Growing..."
			progress_bar.visible = true
			progress_bar.value = 0
			sprite.modulate = Color(0.6, 0.5, 0.3)
		StationState.READY:
			station_label.text = "Ready!"
			progress_bar.visible = false
			sprite.modulate = Color(0.4, 0.7, 0.4)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_nearby = body


func _on_body_exited(body: Node2D) -> void:
	if body == player_nearby:
		player_nearby = null


func _on_growth_timer_timeout() -> void:
	current_state = StationState.READY
	update_display()
	mushroom_ready.emit(resulting_mushroom)
