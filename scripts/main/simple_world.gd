extends Node2D

const PlayerScene := preload("res://scenes/player/player.tscn")

@onready var outside_area: Node2D = $OutsideArea
@onready var inside_area: Node2D = $InsideArea
@onready var player_container: Node2D = $Player
@onready var spawn_point: Marker2D = $PlayerSpawnPoint
@onready var door_trigger: Area2D = $OutsideArea/DoorTrigger
@onready var exit_trigger: Area2D = $InsideArea/ExitTrigger

var player: Player
var is_inside := false
var can_transition := true


func _ready() -> void:
	_spawn_player()

	# Auto-enter/exit on contact
	door_trigger.body_entered.connect(_on_door_entered)
	exit_trigger.body_entered.connect(_on_exit_entered)


func _spawn_player() -> void:
	player = PlayerScene.instantiate()
	player.global_position = spawn_point.global_position
	player_container.add_child(player)


func _on_door_entered(body: Node2D) -> void:
	if body is Player and not is_inside and can_transition:
		enter_house()


func _on_exit_entered(body: Node2D) -> void:
	if body is Player and is_inside and can_transition:
		exit_house()


func enter_house() -> void:
	can_transition = false
	is_inside = true

	# Seamless swap - just change visibility, player stays same position
	outside_area.visible = false
	inside_area.visible = true

	# Brief cooldown to prevent instant re-trigger
	await get_tree().create_timer(0.3).timeout
	can_transition = true


func exit_house() -> void:
	can_transition = false
	is_inside = false

	# Seamless swap - just change visibility
	outside_area.visible = true
	inside_area.visible = false

	# Brief cooldown
	await get_tree().create_timer(0.3).timeout
	can_transition = true
