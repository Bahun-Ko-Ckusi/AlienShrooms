extends Area2D
class_name Spore

@export var spore_type: String = "common"
@export var float_amplitude := 3.0
@export var float_speed := 2.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var float_timer: Timer = $FloatTimer

var base_position: Vector2
var time_offset: float


func _ready() -> void:
	base_position = position
	time_offset = randf() * TAU
	add_to_group("spores")
	add_to_group("interactable")

	# Set color based on type
	match spore_type:
		"common":
			sprite.modulate = Color.YELLOW_GREEN
		"forest":
			sprite.modulate = Color.DARK_GREEN
		"rare":
			sprite.modulate = Color.PURPLE
		"glowing":
			sprite.modulate = Color.CYAN


func _process(delta: float) -> void:
	# Floating animation
	var float_offset := sin(Time.get_ticks_msec() * 0.001 * float_speed + time_offset) * float_amplitude
	position.y = base_position.y + float_offset


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		collect(body)


func interact(player: Player) -> void:
	collect(player)


func collect(player: Player) -> void:
	PlayerData.add_spore(spore_type)

	# Play collection effect
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.tween_callback(queue_free)
