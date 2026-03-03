extends CharacterBody2D
class_name Player

@export var speed := 200.0
@export var jump_velocity := -400.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite: Sprite2D = $Sprite2D
@onready var camera: Camera2D = $Camera2D
@onready var speech_bubble: Label = $SpeechBubble

# Direction sprites
var sprite_south: Texture2D
var sprite_east: Texture2D
var sprite_west: Texture2D
var sprites_loaded := false


func _ready() -> void:
	_load_sprites()


func _load_sprites() -> void:
	sprite_south = load("res://assets/sprites/player/south.png")
	sprite_east = load("res://assets/sprites/player/east.png")
	sprite_west = load("res://assets/sprites/player/west.png")

	if sprite_south:
		sprite.texture = sprite_south
		sprites_loaded = true
		if has_node("Body"):
			$Body.visible = false
		if has_node("Hair"):
			$Hair.visible = false


func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Horizontal movement
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed

	move_and_slide()

	# Update sprite based on direction
	if direction > 0:
		if sprites_loaded:
			sprite.texture = sprite_east
		else:
			sprite.flip_h = false
			if has_node("Body"):
				$Body.scale.x = 1
			if has_node("Hair"):
				$Hair.scale.x = 1
		speech_bubble.visible = true
	elif direction < 0:
		if sprites_loaded:
			sprite.texture = sprite_west
		else:
			sprite.flip_h = true
			if has_node("Body"):
				$Body.scale.x = -1
			if has_node("Hair"):
				$Hair.scale.x = -1
		speech_bubble.visible = true
	else:
		speech_bubble.visible = false
		if is_on_floor() and sprites_loaded:
			# Idle - face forward
			sprite.texture = sprite_south
