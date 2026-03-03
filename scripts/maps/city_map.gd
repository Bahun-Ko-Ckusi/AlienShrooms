extends Node2D

const SporeScene := preload("res://scenes/objects/spore.tscn")

@onready var spore_spawn_points: Node2D = $SporeSpawnPoints
@onready var npcs: Node2D = $NPCs
@onready var unlockable_areas: Node2D = $UnlockableAreas

var active_spores: Array[Spore] = []
var spore_respawn_time := 60.0


func _ready() -> void:
	spawn_initial_spores()
	setup_unlockable_areas()


func spawn_initial_spores() -> void:
	for spawn_point in spore_spawn_points.get_children():
		if spawn_point is Marker2D:
			spawn_spore_at(spawn_point.global_position)


func spawn_spore_at(pos: Vector2, spore_type: String = "") -> Spore:
	var spore := SporeScene.instantiate() as Spore

	# Random type if not specified
	if spore_type.is_empty():
		var types := ["common", "common", "common", "forest", "rare"]
		spore_type = types[randi() % types.size()]

	spore.spore_type = spore_type
	spore.global_position = pos
	add_child(spore)
	active_spores.append(spore)

	# Connect to track when collected
	spore.tree_exited.connect(_on_spore_collected.bind(pos))

	return spore


func _on_spore_collected(pos: Vector2) -> void:
	# Schedule respawn
	var timer := get_tree().create_timer(spore_respawn_time)
	timer.timeout.connect(spawn_spore_at.bind(pos, ""))


func setup_unlockable_areas() -> void:
	for area in unlockable_areas.get_children():
		if area is Area2D:
			var area_name := area.name.to_lower()
			area.body_entered.connect(_on_unlockable_area_entered.bind(area_name))

			# Visual indicator for locked areas
			if not GameManager.is_area_unlocked(area_name):
				area.modulate = Color(1, 1, 1, 0.5)


func _on_unlockable_area_entered(body: Node2D, area_name: String) -> void:
	if body is not Player:
		return

	if GameManager.is_area_unlocked(area_name):
		# Allow entry
		pass
	else:
		# Show unlock requirements
		var required := GameManager.get_area_requirement(area_name)
		var current := PlayerData.total_mushrooms_grown
		print("Need %d mushrooms to unlock %s (you have %d)" % [required, area_name, current])

		# Try to unlock
		if GameManager.try_unlock_area(area_name):
			print("%s unlocked!" % area_name)
