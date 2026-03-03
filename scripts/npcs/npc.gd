extends CharacterBody2D
class_name NPC

signal request_completed(npc_name: String, reward: Dictionary)

@export var npc_name := "Citizen"
@export var dialogue_lines: Array[String] = ["Hello there!"]
@export var can_give_requests := true

@onready var sprite: Sprite2D = $Sprite2D
@onready var name_label: Label = $NameLabel
@onready var request_icon: Sprite2D = $RequestIcon
@onready var interaction_area: Area2D = $InteractionArea

var current_request: Dictionary = {}
var player_nearby: Player = null

# Request templates
var request_templates := [
	{
		"dialogue": "I need some %s mushrooms for my recipe. Can you bring me %d?",
		"mushroom_types": ["button", "shiitake"],
		"min_amount": 1,
		"max_amount": 3,
		"reward_type": "unlock_hint"
	},
	{
		"dialogue": "I'm researching rare fungi. Could you find me %d %s mushrooms?",
		"mushroom_types": ["truffle", "bioluminescent"],
		"min_amount": 1,
		"max_amount": 2,
		"reward_type": "rare_spore"
	}
]


func _ready() -> void:
	add_to_group("npcs")
	add_to_group("interactable")
	name_label.text = npc_name

	if can_give_requests:
		generate_request()


func generate_request() -> void:
	var template: Dictionary = request_templates[randi() % request_templates.size()]
	var mushroom_type: String = template.mushroom_types[randi() % template.mushroom_types.size()]
	var amount: int = randi_range(template.min_amount, template.max_amount)

	current_request = {
		"mushroom_type": mushroom_type,
		"amount": amount,
		"reward_type": template.reward_type,
		"dialogue": template.dialogue % [mushroom_type, amount]
	}

	request_icon.visible = true


func interact(player: Player) -> void:
	if current_request.is_empty():
		# Normal dialogue
		show_dialogue(dialogue_lines[randi() % dialogue_lines.size()])
	else:
		# Check if player can fulfill request
		var mushroom_type: String = current_request.mushroom_type
		var amount: int = current_request.amount

		if PlayerData.has_mushroom(mushroom_type, amount):
			show_fulfillment_dialogue(player)
		else:
			show_request_dialogue()


func show_dialogue(text: String) -> void:
	# Find game UI and show dialogue
	var ui := get_tree().get_first_node_in_group("game_ui")
	if ui and ui.has_method("show_dialogue"):
		ui.show_dialogue(npc_name, text)


func show_request_dialogue() -> void:
	show_dialogue(current_request.dialogue)


func show_fulfillment_dialogue(player: Player) -> void:
	var mushroom_type: String = current_request.mushroom_type
	var amount: int = current_request.amount

	var options := [
		{"text": "Give mushrooms", "action": "give"},
		{"text": "Not now", "action": "decline"}
	]

	# For now, just complete the request
	complete_request(player)


func complete_request(player: Player) -> void:
	var mushroom_type: String = current_request.mushroom_type
	var amount: int = current_request.amount

	PlayerData.remove_mushroom(mushroom_type, amount)

	# Give reward
	var reward := give_reward()

	show_dialogue("Thank you so much! Here's something for your trouble.")

	# Track completion
	var request_id := "%s_%s_%d" % [npc_name, mushroom_type, amount]
	PlayerData.completed_requests.append(request_id)

	request_completed.emit(npc_name, reward)

	# Clear or generate new request
	current_request.clear()
	request_icon.visible = false

	# Generate new request after delay
	await get_tree().create_timer(120.0).timeout
	if can_give_requests:
		generate_request()


func give_reward() -> Dictionary:
	var reward := {}

	match current_request.reward_type:
		"unlock_hint":
			# Give hint about unlockable areas
			reward = {"type": "hint", "value": "There's a secret grove in the forest..."}
		"rare_spore":
			# Give rare spore
			var rare_types := ["rare", "glowing"]
			var spore_type: String = rare_types[randi() % rare_types.size()]
			PlayerData.add_spore(spore_type)
			reward = {"type": "spore", "value": spore_type}

	return reward


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_nearby = body


func _on_body_exited(body: Node2D) -> void:
	if body == player_nearby:
		player_nearby = null
